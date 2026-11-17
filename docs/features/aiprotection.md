# AiProtection (Trend Micro)

**Category:** Security  
**Modes:** Router  
**Status:** `out-of-scope`  
**Kind:** proprietary  
**Required:** no  
**Upstream:** stock ASUS / Trend Micro (proprietary)

## Dependencies

- none

## Build / install (separable)

Nothing to build: closed/licensed component. Stock keeps providing it.

## What it does

Trend Micro security suite: malicious-site blocking, IPS, infected-device blocking, parental filtering.

## How gnuton implements it

Stock ASUS/Trend Micro feature (not gnuton-specific); `bwdpi` + Broadcom DPI (`BCM_DPI`) + Trend Micro signatures.

## Requirements

`BCM_DPI` kernel module, proprietary `bwdpi` userspace, Trend Micro signature DB and licensing/cloud service.

## Franklin approach

Not portable: the daemon and signatures are proprietary and licensed. Stock keeps providing it; Franklin must not disturb it.

## Tested / verified

Not tested; classified from firmware contents.

## Risks / notes

Licensed/proprietary service — cannot be redistributed via Franklin.

## Why this kind (evidence)

stock/proprietary: all 11 `AiProtection_*.asp` pages exist in BOTH rootfs; it is an ASUS/Trend Micro feature gnuton inherits.

## Links / sources

- `docs/firmware-comparison.md`
