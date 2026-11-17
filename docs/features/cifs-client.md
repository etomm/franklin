# CIFS mount (client)

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** n/a — Franklin addition (not in stock or gnuton)

## Dependencies

- [boot-hook](boot-hook.md)
- [kernel-modules](kernel-modules.md)

## Build / install (separable)

Franklin addition: install on USB and start from the boot hook.

## What it does

Mount a remote SMB/CIFS share on the router (e.g. for backups or media).

## How gnuton implements it

Not provided: gnuton ships no `mount.cifs` (verified in its rootfs); Merlin users typically add it via Entware.

## Requirements

Kernel CIFS support (`cifs.ko` built from the ASUS GPL if absent), `mount.cifs` userspace, boot hook to mount at boot.

## Franklin approach

Franklin addition: build/load `cifs.ko` if missing and mount from the boot hook using Entware `cifs-utils`.

## Tested / verified

Neither rootfs ships `mount.cifs`; kernel CIFS support to confirm via the kernel matrix.

## Risks / notes

Needs a matching kernel module; credentials must live on USB/JFFS with tight perms.

## Why this kind (evidence)

franklin-feature: absent from BOTH stock and gnuton rootfs (`usr/sbin/mount.cifs` missing in each), so this is not a gnuton port.

## Links / sources

- `docs/kernel-feature-matrix.md`
