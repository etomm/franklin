# Parental controls

**Category:** Security  
**Modes:** Router  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- [firewall-custom](firewall-custom.md)

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Per-device internet scheduling/blocking and (with AiProtection) content filtering.

## How gnuton implements it

Stock `ParentalControl.asp` + `rc`; content categories come from `bwdpi`.

## Requirements

Stock scheduler/iptables; content filtering needs AiProtection.

## Franklin approach

Time-based blocking stays stock; if Franklin needs it on a different rule set, use iptables + cron from the boot hook. Category filtering is proprietary.

## Tested / verified

Not tested (AP mode: scheduling lives on the main router).

## Risks / notes

Router-mode; content categories need the proprietary DPI engine.

## Why this kind (evidence)

stock: `ParentalControl.asp` exists in BOTH rootfs; only the content categories depend on proprietary DPI.

## Links / sources

- `aiprotection.md`
