# cron / scheduled tasks

**Category:** Automation  
**Modes:** all  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

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
