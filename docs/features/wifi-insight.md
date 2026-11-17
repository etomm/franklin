# WiFi Insight

**Category:** Wireless  
**Modes:** all (mesh/AP)  
**Status:** `stock+`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `www/WiFi_Insight.asp`
