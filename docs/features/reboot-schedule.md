# Reboot schedule

**Category:** Automation  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [cron](cron.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Scheduled automatic reboots.

## How gnuton implements it

cron + nvram `reboot_schedule`; UI on System page.

## Requirements

cron, boot hook.

## Franklin approach

Stock `reboot_schedule` or cron job from boot hook.

## Tested / verified

Page present.

## Risks / notes

Low.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_System_Content.asp`
