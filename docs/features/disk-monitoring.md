# Disk monitoring (smartmontools)

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** entware-package  
**Required:** no  
**Upstream:** n/a - Entware package (smartmontools); neither stock nor gnuton

## Dependencies

- [entware](entware.md)

## Build / install (separable)

`opkg install smartmontools` (Entware), then schedule `smartctl` checks.

## What it does

SMART health and disk temperature for USB/attached drives.

## How gnuton implements it

Not provided: gnuton ships no `smartctl`. Merlin/gnuton users install smartmontools from Entware.

## Requirements

Entware `smartmontools` (`smartctl`), USB storage, boot hook to schedule checks.

## Franklin approach

Franklin-specific: install smartmontools from Entware, run `smartctl -H` from cron/boot hook and surface it on a page.

## Tested / verified

`smartctl` is in NEITHER rootfs, so neither stock nor gnuton can do SMART.

## Risks / notes

USB bridge must pass SMART through; Entware binaries need `unset LD_LIBRARY_PATH`.

## Why this kind (evidence)

entware-package: `smartctl` absent from BOTH rootfs; this is an Entware feature that Franklin integrates, not a gnuton feature.

## Links / sources

- (none yet)
