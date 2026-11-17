# Build architecture: one composition, self-contained features

The USB key is the product. `tools/franklin-compose.py` turns a list of
features into a complete, runnable stick. Nothing at runtime reads the repo.

```
franklin.yaml                    <- what goes on the stick (composition)
features/<id>/feature.yaml       <- what each feature is and needs
features/<id>/payload/           <- files copied into franklin/features/<id>/
features/<id>/build.sh           <- how to produce its artifacts (optional)
tools/franklin-compose.py        <- the composer; verifies, then writes
core/boot/franklin-boot          <- runtime driver, copied into the stick
```

## What the composer writes

```
<usb>/                          (default build/usb, or --out)
  asusware.arm/
    .asusrouter                 marker ASUS looks for
    etc/init.d/S99franklin      thin shim -> ../franklin/bin/franklin-boot
  franklin/
    bin/franklin-boot           discovers its USB base, runs the registry
    registry.d/NN-<id>.env      generated, dependency-ordered
    features/<id>/              payload/ copied verbatim (hooks live here)
    kmod/<uname -r>/            .ko files staged per feature
    bin/                        optional feature binaries (e.g. ipset)
    opt/  state/  log/          preserved state (see below)
    BUILD-INFO                  git sha + feature list (no timestamps)
    SHA256SUMS                  hash of every composed file
```

`franklin/` is **owned** by the composer: on every run it is emptied and
rebuilt. Only `opt/`, `state/` and `log/` are preserved (configurable via
`preserve:` in `franklin.yaml`), so an Entware install, feature enable flags
and logs survive a rebuild.

In `asusware.arm/` Franklin owns exactly two files, `etc/init.d/S99franklin`
and `.asusrouter`. Nothing else in that folder is touched, so an Entware or
ASUS app install there is never clobbered.

## Why `asusware.arm` at all

Verified on the device (stock XT9):

- the USB stick is mounted at `/tmp/mnt/<LABEL>` (currently an **ext3**
  partition, so permissions and symlinks work),
- `/tmp/opt` is a symlink created by ASUS pointing at
  `/tmp/mnt/<LABEL>/asusware.arm`,
- `/opt` is a directory of per-subdir symlinks (`/opt/bin -> /tmp/opt/bin`, …),
  created by ASUS,
- the only boot hook stock actually runs is
  `asusware.arm/etc/init.d/S*.` (verified with our earlier `S99xt9-log` test),
  `/jffs/scripts` is ignored.

So the shim must live in `asusware.arm/etc/init.d/`. Everything else is
Franklin's own tree.

### `/opt` and Entware

Because ASUS points `/tmp/opt` at `asusware.arm`, the boot driver re-points it:

```
/tmp/opt -> /tmp/mnt/<LABEL>/franklin/opt
```

Consequences: `/opt/bin` etc. keep working as a normal Entware layout, Entware
files land in the **preserved** `franklin/opt`, and a rebuild never deletes
installed packages. Set `opt: false` in `franklin.yaml` to leave ASUS's
original link alone.

## feature.yaml schema

```yaml
id: cake-qos                 # must equal the folder name
title: Cake QoS
kind: gnuton-feature         # gnuton-feature | workaround | franklin-feature |
                             # entware-package | stock | proprietary
required: false              # true => cannot be removed
enabled_by_default: false    # runtime flag, overridable in franklin/state/
requires: [kernel-modules]   # feature ids, resolved transitively
provides: [sch_cake.ko]      # documentation of what it makes available
artifacts: [build/cake-qos/sch_cake.ko]   # produced by build.sh
files:                       # copied into the composition
  - src: build/cake-qos/sch_cake.ko
    dst: franklin/kmod/4.19.183/sch_cake.ko
    optional: false          # optional = skip if not built yet
payload: payload             # copied to franklin/features/<id>/
hooks:
  start: start.sh            # run at boot when enabled
  stop: stop.sh              # run on disable/uninstall
build: build.sh              # optional build entrypoint
```

Rules enforced by `--check`:

- `id` matches the folder, ids are unique, `kind` is known;
- `requires` closes transitively, no cycles, no unknown ids;
- every destination stays under `franklin/` (plus the two shim files);
- no two features write the same destination;
- declared hooks exist;
- the dependency closure and `kind` agree with the documented catalog
  (`docs/features/manifest.json`) — drift is an error.

`--without <id>` fails if any remaining feature still needs it, so removing a
feature is a checked operation rather than a hope.

## Runtime behaviour

`franklin-boot`:

1. derives `FRANKLIN_ROOT` from its own path (no hardcoded mount points),
2. re-points `/tmp/opt` when `opt: true`,
3. sources `registry.d/*.env` in order and runs each `start` hook,
4. honours per-feature overrides: `franklin/state/<id>.enabled` /
   `<id>.disabled` beat the default,
5. logs to `franklin/log/boot.log` (rotated at 256 KiB),
6. never aborts: a failing feature is logged and the rest still start,
7. exits 0 so a broken feature cannot make stock think the app failed.

## Determinism

- files copied in sorted order with `mtime = 0`; modes normalised
  (`755` for `.sh`/`.py`, `644` otherwise);
- symlinks are refused (they break on non-ext filesystems and hide tampering);
- `BUILD-INFO` contains no timestamps, only version, git sha, profile, features;
- `SHA256SUMS` covers every composed file, so two builds can be compared
  byte-for-byte.

## Building from Windows

The stick is ext3/ext4, so permissions must come from a Linux-side tool.

```powershell
# structure check (fast, Windows-side)
python tools/franklin-compose.py --check

# real composition, Windows-side (build/usb)
python tools/franklin-compose.py

# deterministic tar for deployment from WSL/Docker
wsl tar --sort=name --mtime=@0 --owner=0 --group=0 -C build/usb -cf franklin.tar .
```

Deployment options, best first:

1. **WSL2 mounting the stick** (`wsl --mount \\.\PHYSICALDRIVE<N> --bare`, then
   mount inside the distro, run the composer with `--out /mnt/wsl/...`) —
   keeps modes/ownership exactly.
2. **tar over SSH** to the router:
   `Get-Content franklin.tar -AsByteStream | ssh admin@router "cd /tmp/mnt/FRANKEN && tar xf -"`
   (no scp needed, works with busybox tar).
3. Docker for the build step only: `docker run --rm -v "$PWD:/src" -w /src
   python:3-slim sh -c "pip install pyyaml && python tools/franklin-compose.py"`.

Format guidance: **ext4** (or the existing ext3) — permissions, symlinks,
journal. Avoid exFAT/vfat: no modes, no symlinks, and every `S*`/hook then has
to be invoked through `sh` explicitly.

## Worked example: the gnuton UI

`web-ui` is data only (gnuton `httpd`, its `/www`, the differing libs);
`web-ui-overlay` is the mechanism that runs it.

```
wsl sh features/web-ui/build.sh     # or: build.sh inside Docker
python tools/franklin-compose.py
```

`build.sh` needs both extracted rootfs trees (stock + gnuton) and stages:

```
build/web-ui/httpd      gnuton /usr/sbin/httpd
build/web-ui/www/       gnuton /www (broken extraction symlinks skipped)
build/web-ui/lib/       every .so that stock lacks or builds differently
```

At boot `web-ui-overlay/start.sh` runs that httpd on `:8088` with
`cwd=franklin/webui/www` and `LD_LIBRARY_PATH=franklin/webui/lib`, after
fixing `acc_num=0` (without it `Advanced_System_Content.asp` segfaults). Stock
`:80` keeps serving the stock UI, so the overlay is always reversible.

Bind mode (gnuton pages served by the *stock* httpd) is opt-in and reversible:

```
touch  franklin/state/web-ui-overlay.bindwww   # then run start.sh
sh     franklin/features/web-ui-overlay/stop.sh   # unmounts /www, restores stock
```

## Adding a feature

1. `features/<id>/feature.yaml` (schema above), `payload/start.sh` (+ `stop.sh`),
2. `build.sh` if it needs artifacts,
3. add the id to `franklin.yaml`,
4. `python tools/franklin-compose.py --check`,
5. `python tools/franklin-compose.py`, then deploy.

Removing a feature: delete its id from `franklin.yaml` (or pass
`--without <id>`), recompose. Its `state/` files and `log/` lines remain
harmless.
