# Custom scripts

**Category:** Automation  
**Modes:** all  
**Status:** `tested`  
**Upstream:** gnuton / Asuswrt-Merlin

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
