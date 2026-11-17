# QoS Classification / Stats

**Category:** QoS  
**Modes:** Router  
**Status:** `research`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `www/QoS_Stats.asp`
