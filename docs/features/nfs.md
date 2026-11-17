# NFS server

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)
- [kernel-modules](kernel-modules.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Export USB/attached storage over NFS.

## How gnuton implements it

Ships `nfsd`, `exportfs`, `mountd`, `portmap`, `statd` and the kernel modules `fs/nfsd/nfsd.ko`, `fs/nfs/nfs.ko`, `exportfs.ko`, `lockd.ko`, `sunrpc.ko` (all present only in gnuton's module tree).

## Requirements

`nfsd.ko`/`nfs.ko`/`exportfs.ko`/`lockd.ko`/`sunrpc.ko` built for 4.19.183 (stock config has no CONFIG_NFS* at all), gnuton NFS userspace binaries, `nfsd` startup from the boot hook, `/etc/exports` on USB/JFFS.

## Franklin approach

Build the NFS modules with the kernel-module recipe, load them from the boot hook, run gnuton's `rpcbind`/`nfsd`/`exportfs` from USB, and expose the gnuton page.

## Tested / verified

gnuton-only modules and binaries confirmed; stock XT9 config has no NFS entries, so modules must be built (not yet done).

## Risks / notes

Two layers must be supplied (kernel modules + userspace); stock cannot serve NFS on its own. Router/AP mode irrelevant, but USB storage must be mounted first.

## Why this kind (evidence)

gnuton-feature: `nfsd.ko`/`nfs.ko`/`exportfs.ko` and `usr/sbin/nfsd` exist ONLY in gnuton; stock's kernel config has no CONFIG_NFS_FS/NFSD.

## Links / sources

- `usr/sbin/nfsd`
- `www/Advanced_AiDisk_NFS.asp`
- `docs/kernel-feature-matrix.md`
