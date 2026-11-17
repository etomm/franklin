# TEE (packet duplication)

**Category:** Network  
**Modes:** all  
**Status:** `tested`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `docs/xt9-kernel-notes.md`
