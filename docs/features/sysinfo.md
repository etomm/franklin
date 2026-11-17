# Tools / Sysinfo

**Category:** Monitoring  
**Modes:** all  
**Status:** `stock+`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

CPU, RAM, temperature graphs, uptime, interface stats.

## How gnuton implements it

Redesigned Sysinfo page (`Tools_Sysinfo.asp`) with graphs.

## Requirements

httpd + www; sysfs/proc.

## Franklin approach

gnuton Sysinfo page via bind-mounted httpd.

## Tested / verified

gnuton sysinfo page loads (200).

## Risks / notes

Low.

## Links / sources

- `www/Tools_Sysinfo.asp`
