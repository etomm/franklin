# Adaptive QoS / DPI

**Category:** QoS  
**Modes:** Router  
**Status:** `research`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [kernel-modules](kernel-modules.md)
- [boot-hook](boot-hook.md)
- [ipset](ipset.md)

## Build / install (separable)

Build BCM_DPI.ko (modularizable per audit) + bwdpi userspace/signatures.

## What it does

ASUS/Trend Micro QoS with DPI classification (Adaptive QoS, Traffic Analyzer).

## How gnuton implements it

`bwdpi` daemon + Broadcom DPI kernel (`BCM_DPI`) + signature DB; pages AdaptiveQoS_*.

## Requirements

BCM_DPI module (modularizable per audit), bwdpi userspace, signatures.

## Franklin approach

Possible if BCM_DPI.ko + bwdpi + signatures can be supplied; audit says BCM_DPI modularizable.

## Tested / verified

Audit: BCM_DPI modularizable; not yet built.

## Risks / notes

Signature DB/service coupling; Router-mode.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/kernel-feature-matrix.md`
