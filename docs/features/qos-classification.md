# QoS Classification / Stats

**Category:** QoS  
**Modes:** Router  
**Status:** `research`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [adaptive-qos](adaptive-qos.md)
- [web-ui](web-ui.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Classify traffic and show upload/download per app/category.

## How gnuton implements it

QoS daemon + DPI; page `QoS_Stats.asp`.

## Requirements

bwdpi/DPI, tc marks.

## Franklin approach

Tied to DPI; see adaptive-qos.

## Tested / verified

Page loads; data depends on DPI.

## Risks / notes

Router-mode.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/QoS_Stats.asp`
