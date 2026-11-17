# NTP client/server

**Category:** System  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Time sync and optional NTP server.

## How gnuton implements it

Ships `ntpd` (gnuton-only) and `ntpd_synced`; stock only has `ntpclient`.

## Requirements

`ntpd` (gnuton binary), boot hook to start it.

## Franklin approach

Use stock `ntpclient` for time sync, and run gnuton's `ntpd` from USB only if an NTP server is wanted.

## Tested / verified

`usr/sbin/ntpd` gnuton-only; `usr/sbin/ntpclient` and `sbin/ntp` stock-only.

## Risks / notes

Low. Two time daemons must not fight over the clock.

## Why this kind (evidence)

gnuton-feature: `ntpd` exists ONLY in gnuton (stock has `ntpclient`), so the NTP *server* is a gnuton addition.

## Links / sources

- `usr/sbin/ntpd`
