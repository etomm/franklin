# Boot hook (asusware.arm)

**Category:** System  
**Modes:** all  
**Status:** `tested`  
**Kind:** franklin-feature  
**Required:** yes  
**Upstream:** n/a — Franklin-specific (stock has no script hooks; Merlin uses /jffs/scripts)

## Dependencies

- none

## Build / install (separable)

Copy usb/asusware.arm to the USB root; boot hook runs S* scripts.

## What it does

Run Franklin at boot from a USB `asusware.arm` app folder.

## How gnuton implements it

n/a — gnuton/Merlin run `/jffs/scripts/*` hooks instead; stock ignores them, so Franklin uses the USB `asusware.arm` app hook.

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
