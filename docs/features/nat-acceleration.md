# NAT acceleration (CTF/FA)

**Category:** Network  
**Modes:** Router  
**Status:** `out-of-scope`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS (Broadcom CTF/FA)

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

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

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/kernel-feature-matrix.md`
