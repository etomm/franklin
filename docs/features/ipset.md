# ipset

**Category:** Network  
**Modes:** all  
**Status:** `tested`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

Kernel sets for efficient IP/MAC matching (used by Skynet, firewalls).

## How gnuton implements it

`ip_set.ko` + `ipset` tool.

## Requirements

`ip_set.ko` (+ hash types) built for 4.19.183; userspace `ipset`.

## Franklin approach

Build ip_set modules from ASUS GPL, load at boot; copy gnuton `ipset`.

## Tested / verified

Built+loaded `ip_set`/`ip_set_hash_ip`; gnuton `ipset` create/add/list/destroy works.

## Risks / notes

Module must match kernel; load before use.

## Links / sources

- `docs/xt9-kernel-notes.md`
- `usr/sbin/ipset`
