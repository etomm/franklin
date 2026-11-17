# NAT acceleration (CTF/FA)

**Category:** Network  
**Modes:** Router  
**Status:** `out-of-scope`  
**Kind:** out-of-scope  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- none

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Hardware cut-through forwarding / flow acceleration for WAN throughput.

## How gnuton implements it

Broadcom driver/kernel built-in (BCM_ENET, pktflow, CTF).

## Requirements

Kernel/driver — not a loadable module.

## Franklin approach

Cannot add via USB; requires kernel rebuild/flash. Note: WireGuard disables it.

## Tested / verified

Config shows it built-in on stock; not modularizable.

## Risks / notes

Firmware-level only.

## Links / sources

- `docs/kernel-feature-matrix.md`
