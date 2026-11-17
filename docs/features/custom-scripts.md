# Custom scripts

**Category:** Automation  
**Modes:** all  
**Status:** `tested`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** gnuton/Merlin (/jffs/scripts) — re-created by Franklin on stock

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Use USB asusware.arm (not /jffs/scripts on stock).

## What it does

Run user scripts at boot / events.

## How gnuton implements it

`/jffs/scripts/*` hooks (Merlin).

## Requirements

On stock, `/jffs/scripts` is NOT honored (gnuton-only).

## Franklin approach

Use the USB `asusware.arm` hook instead; verified it runs at boot.

## Tested / verified

`/jffs/scripts` hooks did not run on stock; USB asusware.arm works.

## Risks / notes

USB must be present at boot.

## Links / sources

- `docs/xt9-notes.md`
