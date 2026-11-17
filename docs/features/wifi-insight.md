# WiFi Insight

**Category:** Wireless  
**Modes:** all (mesh/AP)  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [web-ui](web-ui.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Wireless diagnostics: client RSSI, channel utilization, band info.

## How gnuton implements it

`WiFi_Insight.asp` + wireless data from drivers/daemons.

## Requirements

httpd + www; wl/dhd data.

## Franklin approach

gnuton page via bind-mounted httpd.

## Tested / verified

Page loads (200).

## Risks / notes

Some data may be model-specific.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/WiFi_Insight.asp`
