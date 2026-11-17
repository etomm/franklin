# JFFS partition

**Category:** Storage  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build (stock). Enable JFFS if needed; Franklin only writes configs/logs there.

## What it does

Persistent writable storage. Stock has JFFS; gnuton uses it for `/jffs/configs`, `/jffs/scripts`, VPN Director rules, certs and the Traffic Monitor DB.

## How gnuton implements it

gnuton/Merlin stores persistent configs in `/jffs` and runs its `/jffs/scripts` hooks (a Merlin feature).

## Requirements

Stock JFFS (always present). Not a build dependency.

## Franklin approach

Use `/jffs` for persistent configs/logs, like gnuton. But `/jffs/scripts` hooks are NOT honored on stock; the boot hook lives on USB and can sync/apply config to `/jffs` at boot.

## Tested / verified

JFFS present and writable; `/jffs/scripts` hooks did not run on stock.

## Risks / notes

JFFS is stock (nothing to build). Don't rely on `/jffs/scripts` for boot on stock.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/xt9-notes.md`
