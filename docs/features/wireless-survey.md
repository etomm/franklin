# Wireless Survey

**Category:** Wireless  
**Modes:** all  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [web-ui](web-ui.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Scan neighboring APs (channels, RSSI, security).

## How gnuton implements it

`Advanced_Wireless_Survey.asp` + scan helper.

## Requirements

wireless scan capability; httpd + www.

## Franklin approach

gnuton page via bind-mounted httpd.

## Tested / verified

Page loads (200).

## Risks / notes

Scan may interfere briefly; model-specific.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_Wireless_Survey.asp`
