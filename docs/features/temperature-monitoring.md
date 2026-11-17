# Temperature monitoring

**Category:** Monitoring  
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

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Tools_Sysinfo.asp`
