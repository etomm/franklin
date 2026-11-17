# CIFS mount (client)

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton (ships fs/cifs/cifs.ko; stock kernel has no CIFS)

## Dependencies

- [boot-hook](boot-hook.md)
- [kernel-modules](kernel-modules.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Mount a remote SMB/CIFS share on the router (e.g. for backups or media).

## How gnuton implements it

gnuton ships `fs/cifs/cifs.ko` in its module tree (kernel 4.1.52), so the filesystem is available to it; mounting is done with busybox/Entware tools.

## Requirements

`cifs.ko` built for 4.19.183 from the ASUS GPL (stock kernel has no CONFIG_CIFS at all), a mount helper (`mount -t cifs` or Entware cifs-utils), boot hook to mount at boot.

## Franklin approach

Build `cifs.ko` with the kernel-module recipe, load it from the boot hook and mount the share; credentials live on USB/JFFS.

## Tested / verified

gnuton-only module confirmed (`lib/modules/4.1.52/.../fs/cifs/cifs.ko`); stock XT9 config has no CONFIG_CIFS entry, so the module must be built and is not yet.

## Risks / notes

Needs a matching kernel module; credentials must live on USB/JFFS with tight perms.

## Why this kind (evidence)

gnuton-feature: `cifs.ko` exists ONLY in the gnuton module tree and stock's 4.19.183 config has no CIFS support, so stock cannot mount CIFS and gnuton can.

## Links / sources

- `docs/kernel-feature-matrix.md`
- `docs/xt9-kernel-notes.md`
