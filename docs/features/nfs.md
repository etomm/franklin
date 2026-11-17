# NFS server

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Export USB/attached storage over NFS.

## How gnuton implements it

`nfsd`, `exportfs`, `mountd`, `portmap`, `statd` (gnuton /usr/sbin) + pages.

## Requirements

kernel NFS support (check config), nfs-utils binaries, config.

## Franklin approach

Run gnuton NFS binaries if kernel supports NFS; else Entware.

## Tested / verified

gnuton binaries present; kernel NFS support to verify.

## Risks / notes

Kernel NFS may be absent; check config.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `usr/sbin/nfsd`
- `www/Advanced_AiDisk_NFS.asp`
