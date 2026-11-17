# AiDisk NFS

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [nfs](nfs.md)
- [web-ui](web-ui.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

NFS export config page for AiDisk.

## How gnuton implements it

`Advanced_AiDisk_NFS.asp` + nfs daemons.

## Requirements

see nfs feature.

## Franklin approach

gnuton page + NFS daemons.

## Tested / verified

Page loads; daemons not yet.

## Risks / notes

Depends on nfs feature.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_AiDisk_NFS.asp`
