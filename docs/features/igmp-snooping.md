# IGMP snooping / multicast

**Category:** Network  
**Modes:** Router / AP  
**Status:** `out-of-scope`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS / kernel driver

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Multicast group management for IPTV/streaming so multicast is not flooded to every port and wireless client.

## How gnuton implements it

Kernel bridge multicast snooping plus switch-driver multicast tables; toggled through nvram by `rc`.

## Requirements

Kernel bridge IGMP snooping support and switch-driver multicast tables.

## Franklin approach

Mostly firmware/driver-level: only nvram/sysfs toggles are reachable from userspace; full support needs a kernel switch-driver change.

## Tested / verified

Not tested; classified from kernel config/audit.

## Risks / notes

Kernel/driver-level; may be partially toggleable via nvram but not fully ported.

## Why this kind (evidence)

stock/driver-level: no IGMP/multicast page in either rootfs and no gnuton-only binary; identical in stock.

## Links / sources

- `docs/kernel-feature-matrix.md`
