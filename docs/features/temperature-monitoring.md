# Temperature monitoring

**Category:** Monitoring  
**Modes:** all  
**Status:** `stock+`  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [web-ui](web-ui.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

CPU/radio temperature sensors.

## How gnuton implements it

Sysinfo graphs; sysfs.

## Requirements

sysfs thermal.

## Franklin approach

Sysinfo page (gnuton) + sysfs.

## Tested / verified

Sysinfo page loads.

## Risks / notes

Model-specific sensors.

## Links / sources

- `www/Tools_Sysinfo.asp`
