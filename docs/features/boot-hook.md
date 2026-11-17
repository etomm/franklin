# Boot hook (asusware.arm)

**Category:** System  
**Modes:** all  
**Status:** `tested`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

Run Franklin at boot from a USB `asusware.arm` app folder.

## How gnuton implements it

n/a (ns). Merlin uses `/jffs/scripts`.

## Requirements

USB with `asusware.arm/`, `S*` init scripts, `Enabled: yes` control file.

## Franklin approach

Primary boot hook on stock; verified.

## Tested / verified

Verified: S99xt9-log ran at boot.

## Risks / notes

USB must be present; runs late (after services).

## Links / sources

- `docs/xt9-notes.md`
