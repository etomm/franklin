# TEE (packet duplication)

**Category:** Network  
**Modes:** all  
**Status:** `tested`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [kernel-modules](kernel-modules.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

Run features/tee/build.sh -> builds xt_TEE.ko + nf_dup_ipv4/6.ko.

## What it does

Netfilter target that duplicates packets to a gateway (mirroring/IDS).

## How gnuton implements it

`xt_TEE.ko` + `nf_dup_ipv4/6`.

## Requirements

`xt_TEE.ko`, `nf_dup_ipv4/6.ko` (stock lacks NF_DUP).

## Franklin approach

Build/load modules from ASUS GPL; use with iptables.

## Tested / verified

Built all three; insmod OK; `iptables -j TEE --gateway ...` add/list/del works.

## Risks / notes

Module match; load order.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/xt9-kernel-notes.md`
