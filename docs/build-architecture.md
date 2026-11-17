# Build architecture: one composition, self-contained features

The USB key is the product. `tools/franklin-compose.py` turns a list of
features into a complete, runnable stick. Nothing at runtime reads the repo.

```
franklin.yaml                    <- what goes on the stick (composition)
features/<id>/feature.yaml       <- what each feature is and needs
features/<id>/payload/           <- the feature's own files, ready to run
features/<id>/build.sh           <- stages generated files into payload/
tools/franklin-compose.py        <- the composer; verifies, then writes
core/boot/franklin-boot          <- runtime driver, copied into the stick
```

**No file mapping.** A feature's `payload/` folder *is* the folder it gets on
the stick. Shared directories merge into one prefix, exactly like a package
installing into `/opt`; everything else stays private to the feature:

| In `payload/` | Lands at | Why |
|---|---|---|
| `opt/`, `bin/`, `sbin/`, `lib/`, `etc/`, `share/`, `var/` | `franklin/<dir>/` (merged) | shared prefix: binaries, libs, configs |
| anything else (`start.sh`, `.ko`, data) | `franklin/features/<id>/` | private to the feature |

So `payload/opt/bin/ipset` becomes `/opt/bin/ipset` at runtime, and
`payload/start.sh` becomes `franklin/features/ipset/start.sh`.

The composer **fails on a file collision** (same path from two features with
different content) and writes a generated `franklin/OWNERS` map
(`path<TAB>feature`) so removing a feature stays exact without anyone
hand-maintaining a file list.

## What the composer writes

```
<usb>/                          (default build/usb, or --out)
  asusware.arm/
    .asusrouter                 marker ASUS looks for
    etc/init.d/S99franklin      thin shim -> ../franklin/bin/franklin-boot
  franklin/
    bin/franklin-boot           discovers its USB base, runs the registry
    registry.d/NN-<id>.env      generated, dependency-ordered
    features/<id>/              private per-feature files, hooks live here
    opt/ bin/ sbin/ lib/ etc/ share/ var/   merged from all features
    opt/  state/  log/          preserved state (see below)
    BUILD-INFO                  git sha + feature list (no timestamps)
    OWNERS                      which feature owns each merged file
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

The `/opt` prefix already exists on stock — ASUS creates the whole symlink farm
at boot (`/opt/bin -> /tmp/opt/bin`, `/opt/etc -> /tmp/opt/etc`, …) and points
`/tmp/opt` at `asusware.arm`. Verified on the XT9. **Nothing has to be
recreated.**

The boot driver only re-points that single symlink:

```
/tmp/opt -> /tmp/mnt/<LABEL>/franklin/opt
```

Consequences: `/opt/bin`, `/opt/lib`, `/opt/etc`, … immediately resolve into
Franklin's merged tree, Entware installs into the **preserved** `franklin/opt`
and survives rebuilds, and Franklin binaries are simply files in `opt/bin`.

One gap stock leaves: `PATH` is `/usr/sbin:/usr/bin:/sbin:/bin`, with no
`/opt/bin`. The driver prepends `franklin/opt/bin:franklin/opt/sbin` for
everything it starts (verified on the device).

Set `opt: false` in `franklin.yaml` to leave ASUS's original link alone.

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
payload: payload             # copied verbatim to franklin/features/<id>/
hooks:
  start: start.sh            # run at boot when enabled
  stop: stop.sh              # run on disable/uninstall
build: build.sh              # optional: stages generated files into payload/
```

That is the whole manifest — there is no table of source and destination
paths. `payload/sch_cake.ko` lands as
`franklin/features/cake-qos/sch_cake.ko`, and `start.sh` loads it from there.

Rules enforced by `--check`:

- `id` matches the folder, ids are unique, `kind` is known;
- `requires` closes transitively, no cycles, no unknown ids;
- declared hooks exist (looked up in `payload/`);
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

Format guidance: **ext4** (reformat — see below). Avoid exFAT/vfat: no modes, no
symlinks, no xattrs, and overlayfs cannot use it as an upper layer.

## Filesystem: switch the stick to ext4

Checked on the XT9: the stock kernel has `CONFIG_EXT4_FS=y` (ext4 is built in),
so an ext4 stick mounts natively; the router only ships `mkfs.ext2`/`mkfs.ext3`,
so format it from WSL/PC. Overlayfs needs `d_type` and xattrs on the upper
layer; ext3 happens to work today (verified), ext4 guarantees it and adds
extents + journal checksums.

```powershell
# from WSL (stick unplugged from the router, attached to the PC)
wsl -d Debian -u root --mount \\.\PHYSICALDRIVE<N> --bare
wsl -d Debian -u root sh -c "mkfs.ext4 -L FRANKLIN /dev/sdX"
```

Then copy the composition back and re-plug. Nothing in Franklin hardcodes the
mount point or the label (the shim derives the USB base from its own path), so
a new label/`/tmp/mnt/<name>` needs no code change.

## Mounts: overlay first, bind as fallback

The stock rootfs is a read-only squashfs, and ASUS's busybox `mount` refuses
any target on it (`Invalid mount path(/www)`), even though the kernel allows it.

So Franklin does two things:

1. **`overlayfs` feature** builds `overlay.ko` + `exportfs.ko` from the ASUS
   GPL (stock has `CONFIG_OVERLAY_FS` unset) and loads them at boot;
2. **`franklin-mount` feature** is a ~20 line static binary that calls
   `mount(2)`/`umount(2)` directly, sidestepping the busybox restriction.

Verified on the device: bind over `/www`, bind over `/usr/sbin/httpd`, and the
overlay chain (`overlay` at a scratch dir with `lowerdir=<gnuton www>:/www`,
`upperdir`/`workdir` on the USB, then bind that over `/www`) — copy-up on write,
whiteouts, and `umount` restores the stock tree bit-for-bit.

Replace-mode mechanics:

```
/www             <- overlay(gnuton tree : stock /www)   [fallback: single bind]
/usr/sbin/httpd  <- wrapper script (LD_LIBRARY_PATH + exec gnuton-httpd)
/sbin/rc restart_httpd
```

Why the split: `/www` is a tree (overlay is the right tool, and stock pages stay
reachable as the lower layer), while the daemon is a single file that `rc`
restarts by absolute path (a wrapper is the only way to inject the library
path). Everything is a mount, so `stop.sh` — or a reboot — restores stock.

## Worked example: the gnuton UI

`web-ui` is data only (gnuton `httpd`, its `/www`, the differing libs);
`web-ui-overlay` is the mechanism that runs it.

```
wsl sh features/web-ui/build.sh     # or: build.sh inside Docker
python tools/franklin-compose.py
```

`build.sh` needs both extracted rootfs trees (stock + gnuton) and writes
straight into the feature's own payload folder:

```
features/web-ui/payload/opt/bin/gnuton-httpd      gnuton /usr/sbin/httpd
features/web-ui/payload/opt/share/gnuton-www/     gnuton /www (broken links skipped)
features/web-ui/payload/opt/lib/gnuton/           every .so stock lacks or differs
```

Namespaced on purpose: `gnuton-httpd` will not shadow `httpd`, and
`opt/lib/gnuton` keeps gnuton's 219 libraries away from Entware's `opt/lib`.

Those generated files are gitignored; the folder is the whole contract.

At boot `web-ui-overlay/start.sh` runs that httpd on `:8088` with
`cwd=/opt/share/gnuton-www` and `LD_LIBRARY_PATH=/opt/lib/gnuton`, after
fixing `acc_num=0` (without it `Advanced_System_Content.asp` segfaults). Stock
`:80` keeps serving the stock UI, so this mode is always safe.

### Replace mode: making `:80` *be* gnuton

```
touch franklin/state/web-ui-overlay.replace
sh    franklin/features/web-ui-overlay/start.sh
```

Stock runs httpd from a **read-only squashfs**, so `cp` is not an option; the
swap is done with bind mounts over the files:

```
/usr/sbin/httpd  <- franklin/state/httpd-wrapper.sh   (sets LD_LIBRARY_PATH, execs gnuton-httpd)
/www             <- /opt/share/gnuton-www
/sbin/rc restart_httpd
```

The wrapper is not cosmetic: `rc` restarts `/usr/sbin/httpd` by itself, so the
replacement has to work when *stock* starts it, not just when we do — and the
gnuton-only libs need `LD_LIBRARY_PATH`.

Safety: before touching anything, `start.sh` runs the gnuton binary on `:8089`
and requires it to answer; after the swap it requires `:80` to answer, otherwise
it unmounts both and restarts the stock httpd. `stop.sh` performs the same
rollback at any time.

Why `gnuton-httpd` and not `httpd`: in the merged `/opt/bin` a file literally
named `httpd` would shadow the stock binary in `PATH` while doing nothing for
`rc` (which uses the absolute path), giving the illusion of a replacement. The
name is namespaced; the *replacement* is the bind mount.
(without it `Advanced_System_Content.asp` segfaults). Stock `:80` keeps serving
the stock UI, so the overlay is always reversible.

Lightweight variant, when you only want gnuton's pages on top of the stock
daemon (no restart, no binary swap) — parallel mode with `bindwww`:

```
touch  franklin/state/web-ui-overlay.bindwww      # then run start.sh
sh     franklin/features/web-ui-overlay/stop.sh   # unmounts /www, restores stock
```

## Adding a feature

1. `features/<id>/feature.yaml` (schema above), `payload/start.sh` (+ `stop.sh`),
2. `build.sh` if files must be staged from outside the repo (it writes into `payload/`),
3. add the id to `franklin.yaml`,
4. `python tools/franklin-compose.py --check`,
5. `python tools/franklin-compose.py`, then deploy.

Removing a feature: delete its id from `franklin.yaml` (or pass
`--without <id>`), recompose. Its `state/` files and `log/` lines remain
harmless.
