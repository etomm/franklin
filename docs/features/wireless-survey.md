# Wireless Survey

**Category:** Wireless  
**Modes:** all  
**Status:** `stock+`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `www/Advanced_Wireless_Survey.asp`
