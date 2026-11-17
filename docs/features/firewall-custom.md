# Custom firewall / NAT rules

**Category:** Network  
**Modes:** Router  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

iptables/nat rules applied from the USB boot hook.

## What it does

Add iptables/nat rules (port forwarding beyond UI, custom NAT, marks).

## How gnuton implements it

Merlin `/jffs/scripts/firewall-start`, `nat-start` hooks; iptables.

## Requirements

iptables (stock), a boot hook (USB asusware.arm on stock).

## Franklin approach

Run rules from the USB boot hook (since /jffs/scripts is not honored on stock).

## Tested / verified

USB asusware.arm hook verified; /jffs/scripts NOT honored on stock.

## Risks / notes

Router-mode; rules reset on service restart — re-apply.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/xt9-notes.md`
