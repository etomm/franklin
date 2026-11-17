# Traffic Monitor

**Category:** Monitoring  
**Modes:** Router (WAN stats); AP limited  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [web-ui](web-ui.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Realtime/history WAN traffic graphs, per-client stats.

## How gnuton implements it

Redesigned pages using Chart.js; stats stored in JFFS.

## Requirements

httpd + www; nvram/stats DB.

## Franklin approach

gnuton Traffic Monitor pages via bind-mounted httpd; data from stock daemons.

## Tested / verified

gnuton pages load via :8088.

## Risks / notes

Needs gnuton data paths; AP mode limited.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Main_TrafficMonitor_realtime.asp`
