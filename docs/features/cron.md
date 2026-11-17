# cron / scheduled tasks

**Category:** Automation  
**Modes:** all  
**Status:** `planned`  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Entware cron or stock cru; re-add at boot.

## What it does

Scheduled jobs (maintenance, watchdogs, reboots).

## How gnuton implements it

Entware cron or stock `cru`; `Reboot schedule` UI.

## Requirements

cron/cru, boot hook.

## Franklin approach

Use Entware cron or stock `cru` from boot hook.

## Tested / verified

Not yet.

## Risks / notes

Entware LD_LIBRARY_PATH; re-add jobs at boot.

## Links / sources

- (none yet)
