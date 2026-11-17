#!/usr/bin/env python3
"""Compose the Franklin USB tree from feature folders.

Reads:
  franklin.yaml                 which features go on the stick
  features/<id>/feature.yaml    per-feature declaration (deps, files, hooks)

Writes (default build/usb):
  asusware.arm/.asusrouter                      marker ASUS looks for
  asusware.arm/etc/init.d/S99franklin           the only boot hook (thin shim)
  franklin/bin/franklin-boot                    runtime driver
  franklin/registry.d/NN-<id>.env               generated, dependency-ordered
  franklin/features/<id>/                       payload/ copied per feature
  franklin/BUILD-INFO                           sha, feature list, no timestamps
  franklin/SHA256SUMS                           hashes of every composed file

Guarantees:
  * a feature is only included with all of its dependencies (or the run fails),
  * removed features cannot be silently depended on (--without),
  * path traversal, duplicate destinations and unknown ids are errors,
  * output is deterministic (sorted copy, mtime 0, no timestamps in metadata).

Usage:
  python tools/franklin-compose.py                 # compose into build/usb
  python tools/franklin-compose.py --check         # verify, write nothing
  python tools/franklin-compose.py --without tee   # drop a feature
  python tools/franklin-compose.py --out D:/usb    # compose onto a real stick
  python tools/franklin-compose.py --strict        # warnings become errors
"""
import argparse
import hashlib
import json
import os
import shutil
import sys

try:
    import yaml
except ImportError:
    raise SystemExit("PyYAML is required: pip install pyyaml")

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
FEATURES = os.path.join(ROOT, "features")
CATALOG = os.path.join(ROOT, "docs", "features", "manifest.json")
SHIM_DIR = "asusware.arm/etc/init.d"
SHIM = "S99franklin"

REQUIRED_KEYS = ("id", "kind")
KINDS = {"gnuton-feature", "workaround", "franklin-feature", "entware-package",
         "stock", "proprietary"}


class Fail(Exception):
    pass


def load_yaml(path):
    with open(path, encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    if not isinstance(data, dict):
        raise Fail("%s: expected a mapping" % path)
    return data


def load_features():
    feats = {}
    if not os.path.isdir(FEATURES):
        raise Fail("no features/ directory")
    for name in sorted(os.listdir(FEATURES)):
        path = os.path.join(FEATURES, name, "feature.yaml")
        if not os.path.isfile(path):
            continue
        data = load_yaml(path)
        for key in REQUIRED_KEYS:
            if key not in data:
                raise Fail("%s: missing '%s'" % (path, key))
        fid = data["id"]
        if fid != name:
            raise Fail("%s: id '%s' does not match folder '%s'" % (path, fid, name))
        if fid in feats:
            raise Fail("%s: duplicate feature id '%s'" % (path, fid))
        if data["kind"] not in KINDS:
            raise Fail("%s: unknown kind '%s'" % (path, data["kind"]))
        data.setdefault("requires", [])
        data.setdefault("hooks", {})
        data.setdefault("enabled_by_default", False)
        data["_dir"] = os.path.join(FEATURES, name)
        feats[fid] = data
    if not feats:
        raise Fail("no features/*/feature.yaml found")
    return feats


def closure(selected, feats):
    out, stack = set(), list(selected)
    while stack:
        fid = stack.pop()
        if fid in out:
            continue
        if fid not in feats:
            raise Fail("feature '%s' has no features/%s/feature.yaml" % (fid, fid))
        out.add(fid)
        for dep in feats[fid]["requires"]:
            if dep not in feats:
                raise Fail("'%s' requires '%s', which has no feature.yaml" % (fid, dep))
            stack.append(dep)
    return out


def order_of(selected, feats):
    """Deterministic topological order (dependencies first)."""
    done, order, visiting = set(), [], set()

    def visit(fid):
        if fid in done:
            return
        if fid in visiting:
            raise Fail("dependency cycle through '%s'" % fid)
        visiting.add(fid)
        for dep in sorted(feats[fid]["requires"]):
            visit(dep)
        visiting.discard(fid)
        done.add(fid)
        order.append(fid)

    for fid in sorted(selected):
        visit(fid)
    return order


def hook_path(feat, rel):
    """Hooks ship inside the feature payload, so the runtime path is stable."""
    payload = os.path.join(feat["_dir"], "payload", rel)
    if os.path.isfile(payload):
        return payload
    return os.path.join(feat["_dir"], rel)


def check_catalog_drift(feats, strict, problems):
    """feature.yaml must agree with the documented catalog (kind + deps)."""
    if not os.path.isfile(CATALOG):
        problems.append("catalog manifest.json missing; run tools/feature-catalog.py")
        return
    with open(CATALOG, encoding="utf-8") as fh:
        catalog = {f["id"]: f for f in json.load(fh)["features"]}

    def close(start, deps_of):
        seen, stack = set(), list(start)
        while stack:
            fid = stack.pop()
            if fid in seen or fid not in deps_of:
                continue
            seen.add(fid)
            stack.extend(deps_of[fid])
        return seen

    doc_deps = {fid: f["depends_on"] for fid, f in catalog.items()}
    for fid, feat in sorted(feats.items()):
        doc = catalog.get(fid)
        if not doc:
            problems.append("%s: not in the catalog (docs/features/manifest.json)" % fid)
            continue
        if doc["kind"] != feat["kind"]:
            problems.append("%s: kind '%s' in feature.yaml but '%s' in the catalog"
                            % (fid, feat["kind"], doc["kind"]))
        mine = close(feat["requires"], {k: v["requires"] for k, v in feats.items()})
        theirs = close(doc["depends_on"], doc_deps)
        if mine != theirs:
            problems.append("%s: dependency closure differs (feature.yaml %s, catalog %s)"
                            % (fid, sorted(mine), sorted(theirs)))
        if doc["required"] and not feat.get("required"):
            problems.append("%s: required in the catalog, not in feature.yaml" % fid)


def verify(feats, selected, order, strict):
    problems, warnings = [], []
    for fid in order:
        feat = feats[fid]
        for hook, rel in sorted(feat["hooks"].items()):
            if not os.path.isfile(hook_path(feat, rel)):
                problems.append("%s: hook '%s' missing (%s)" % (fid, hook, rel))
        payload = os.path.join(feat["_dir"], "payload")
        if not os.path.isdir(payload) and not feat["hooks"]:
            warnings.append("%s: no payload and no hooks (nothing to compose)" % fid)
    check_catalog_drift(feats, strict, problems)
    if strict:
        problems.extend(warnings)
        warnings = []
    return problems, warnings


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def copy_tree(src, dst, out_files):
    """Deterministic copy: sorted, mtime 0, symlinks refused."""
    if os.path.islink(src):
        raise Fail("refusing to copy symlink: %s" % src)
    if os.path.isdir(src):
        os.makedirs(dst, exist_ok=True)
        for name in sorted(os.listdir(src)):
            copy_tree(os.path.join(src, name), os.path.join(dst, name), out_files)
        return
    if not os.path.isfile(src):
        raise Fail("not a regular file (broken symlink?): %s" % src)
    os.makedirs(os.path.dirname(dst) or ".", exist_ok=True)
    shutil.copyfile(src, dst)
    os.utime(dst, (0, 0))
    os.chmod(dst, 0o755 if src.endswith((".sh", ".py")) else 0o644)
    out_files.append(dst)


def write_file(path, text, mode=0o644, out_files=None):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)
    os.utime(path, (0, 0))
    os.chmod(path, mode)
    if out_files is not None:
        out_files.append(path)


def registry_entry(fid, feat):
    hooks = feat["hooks"]
    lines = [
        "FRANKLIN_FEATURE=%s" % fid,
        "FRANKLIN_KIND=%s" % feat["kind"],
        "FRANKLIN_DIR=$FRANKLIN_ROOT/features/%s" % fid,
        "FRANKLIN_START=%s" % (hooks.get("start", "")),
        "FRANKLIN_STOP=%s" % (hooks.get("stop", "")),
        "FRANKLIN_VERIFY=%s" % (hooks.get("verify", "")),
        "FRANKLIN_ENABLED=%s" % ("1" if feat["enabled_by_default"] else "0"),
    ]
    return "\n".join(lines) + "\n"


def git_sha():
    head = os.path.join(ROOT, ".git", "HEAD")
    if not os.path.isfile(head):
        return "unknown"
    with open(head, encoding="utf-8") as fh:
        ref = fh.read().strip()
    if ref.startswith("ref: "):
        path = os.path.join(ROOT, ".git", ref[5:])
        if os.path.isfile(path):
            with open(path, encoding="utf-8") as fh:
                return fh.read().strip()[:12]
    return ref[:12]


SHIM_TEXT = """#!/bin/sh
# Franklin boot shim (generated by tools/franklin-compose.py).
# Stock firmware only runs scripts from an asusware.* app folder; everything
# else lives in franklin/ next to it.
self="$0"
while [ -L "$self" ]; do self=$(readlink "$self"); done
appdir=$(cd "$(dirname "$self")/../.." && pwd)
usb=$(dirname "$appdir")
exec /bin/sh "$usb/franklin/bin/franklin-boot"
"""


def compose(args, feats, order, cfg):
    out = os.path.abspath(args.out or os.path.join(ROOT, "build", "usb"))
    franklin = os.path.join(out, "franklin")
    preserve = set(cfg.get("preserve") or [])

    # Own the tree: remove everything except the preserved state dirs.
    if os.path.isdir(franklin):
        for name in sorted(os.listdir(franklin)):
            if name in preserve:
                continue
            target = os.path.join(franklin, name)
            if os.path.isdir(target):
                shutil.rmtree(target)
            else:
                os.remove(target)
    else:
        os.makedirs(franklin)
    for name in sorted(preserve):
        os.makedirs(os.path.join(franklin, name), exist_ok=True)

    written = []
    # Each feature folder is copied verbatim: features/<id>/payload ->
    # franklin/features/<id>. The folder layout *is* the destination layout,
    # so there is no src/dst mapping to maintain.
    for fid in order:
        payload = os.path.join(feats[fid]["_dir"], "payload")
        if os.path.isdir(payload):
            copy_tree(payload, os.path.join(franklin, "features", fid), written)

    # runtime driver + registry
    copy_tree(os.path.join(ROOT, "core", "boot", "franklin-boot"),
              os.path.join(franklin, "bin", "franklin-boot"), written)
    reg = os.path.join(franklin, "registry.d")
    for i, fid in enumerate(order, 1):
        write_file(os.path.join(reg, "%02d-%s.env" % (i * 10, fid)),
                   registry_entry(fid, feats[fid]), 0o644, written)

    # ASUS app folder: exactly the two files Franklin owns there
    write_file(os.path.join(out, SHIM_DIR, SHIM), SHIM_TEXT, 0o755, written)
    write_file(os.path.join(out, "asusware.arm", ".asusrouter"), "", 0o644, written)

    # metadata (no timestamps -> reproducible)
    info = [
        "franklin-version: 1",
        "git: %s" % git_sha(),
        "profile: %s" % (cfg.get("profile") or ""),
        "opt: %s" % bool(cfg.get("opt")),
        "features:",
    ]
    info += ["  - %s (%s)" % (fid, feats[fid]["kind"]) for fid in order]
    info.append("order: %s" % ", ".join(order))
    write_file(os.path.join(franklin, "BUILD-INFO"), "\n".join(info) + "\n", 0o644, written)

    sums = []
    for path in sorted(written):
        rel = os.path.relpath(path, out).replace("\\", "/")
        sums.append("%s  %s" % (sha256(path), rel))
    write_file(os.path.join(franklin, "SHA256SUMS"), "\n".join(sums) + "\n", 0o644, None)

    return out, len(order), len(sums)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default=os.path.join(ROOT, "franklin.yaml"))
    ap.add_argument("--out", default=None)
    ap.add_argument("--without", default="")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()

    try:
        cfg = load_yaml(args.config)
        feats = load_features()
        selected = set(feats) if (args.all or cfg.get("all")) else set(cfg["features"])
        required = {fid for fid, f in feats.items() if f.get("required")}
        without = {x.strip() for x in args.without.split(",") if x.strip()}

        unknown = selected - set(feats)
        if unknown:
            raise Fail("unknown feature(s) in %s: %s" % (args.config, ", ".join(sorted(unknown))))
        dropped_required = required & without
        if dropped_required:
            raise Fail("cannot remove required feature(s): %s" % ", ".join(sorted(dropped_required)))

        selected = closure(selected | required, feats) - without
        broken = [(fid, dep) for fid in selected for dep in feats[fid]["requires"]
                  if dep in without]
        if broken:
            raise Fail("removing these breaks selected features:\n" +
                       "\n".join("  %s requires %s" % b for b in broken))

        order = order_of(selected, feats)
        problems, warnings = verify(feats, selected, order, args.strict)
        for w in warnings:
            print("warning: %s" % w)
        if problems:
            raise Fail("verification failed:\n" + "\n".join("  " + p for p in problems))

        if args.check:
            print("OK: %d features compose cleanly: %s"
                  % (len(order), " -> ".join(order)))
            return
        out, n, files = compose(args, feats, order, cfg)
        print("composed %d features (%d files) into %s" % (n, files, out))
    except Fail as exc:
        raise SystemExit(str(exc))


if __name__ == "__main__":
    main()
