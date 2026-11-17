# cron / scheduled tasks

**Category:** Automation  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS (crond/cru); gnuton only adds the crontab command

## Dependencies

- none

## Build / install (separable)

Use stock `cru` from the boot hook; jobs are RAM-based, so re-add them at boot.

## What it does

Scheduled jobs (maintenance, watchdogs, reboots).

## How gnuton implements it

Uses the stock `crond`/`cru` and adds the `crontab` command; ships no cron daemon of its own.

## Requirements

`crond`/`cru` (stock).

## Franklin approach

Schedule jobs with stock `cru` from the boot hook and re-add them at boot (RAM-based). No Entware and no daemon to install.

## Tested / verified

`usr/sbin/crond` and `usr/sbin/cru` present in BOTH rootfs; gnuton adds only `usr/bin/crontab`.

## Risks / notes

Jobs live in RAM and vanish on reboot; `/jffs/scripts` is not honored on stock.

## Why this kind (evidence)

stock: `crond` and `cru` exist in BOTH rootfs (`crontab` is gnuton-only convenience), so cron is a stock feature.

## Links / sources

- (none yet)
