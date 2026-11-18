# entware — optional, self-contained feature tree

Entware is **not** part of gnuton and **not** part of Franklin's default
composition. It lives here as an independent feature so it can be added only
when a plan actually needs a package that exists nowhere else (smartmontools,
aria2, tcpdump, …). Nothing else in the composition depends on it.

## Enabling it

```sh
python tools/franklin-compose.py --add entware          # this build only
```

or uncomment the `- entware` line in `franklin.yaml` to make it permanent.

Disabling it again is just as simple (no `--add`, or `--without entware`), and
nothing else breaks: `franklin/opt` exists anyway (the web UI's libraries live
there), so the `/opt` prefix that ASUS creates keeps working.

## What the feature does

```
features/entware/
  feature.yaml        kind: franklin-feature, Requires: boot-hook
  payload/start.sh    ensures franklin/opt/{bin,sbin,lib,etc,tmp,var} exist,
                      reports whether opkg is installed; installs nothing
  payload/stop.sh     no-op (packages are data on the USB, never removed here)
```

It deliberately does **not** install opkg by itself. Installing Entware means
running its own bootstrap script once, with the prefix pointing at the stick:

1. boot driver points `/tmp/opt` at `<usb>/franklin/opt` (see `franklin.yaml: opt: true`)
2. run the upstream Entware installer (`generic.sh`) for `armv7sf-k3.2`, targeting
   that prefix
3. from then on `/opt/bin/opkg` works and survives rebuilds, because the
   composer never deletes files it did not write (`OWNERS`)

## Why it stays separate

* gnuton ships no opkg (verified) — so this is a Franklin enabler, not a port.
* Its binaries are built for its own libc: run them with `LD_LIBRARY_PATH`
  unset, and never expect them to replace gnuton's `httpd`/`libovpn` or the
  kernel modules built from the ASUS GPL.
* Plans that only exist in Entware are tagged `Kind: entware-package` and
  declare `depends_on: [entware]`, so the planner refuses to build them unless
  this feature is included.
