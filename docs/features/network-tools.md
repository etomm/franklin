# Network Tools

**Category:** Diagnostics  
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

Ping, traceroute, nslookup, Wake-on-LAN, netstat.

## How gnuton implements it

`Main_Netstat_Content.asp`, `Main_WOL_Content.asp`, network tools pages.

## Requirements

stock binaries + httpd + www.

## Franklin approach

gnuton pages via bind-mounted httpd.

## Tested / verified

Pages present on stock.

## Risks / notes

Low.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Main_Netstat_Content.asp`
- `www/Main_WOL_Content.asp`
