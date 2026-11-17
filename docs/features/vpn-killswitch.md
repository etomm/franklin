# VPN Killswitch

**Category:** VPN  
**Modes:** Router (WAN + VPN client)  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

Blocks all traffic that would bypass the VPN tunnel (prohibit rule on the main routing table), applied before WAN comes up to prevent leaks.

## How gnuton implements it

Rewritten in Merlin `rc`: always-present `prohibit` rule; per-client; WireGuard support; rules created before WAN up.

## Requirements

iptables/ip rules; VPN client enabled; nvram `vpn_client*` flags.

## Franklin approach

Reimplement the ip/iptables rules in a boot hook; no rc swap. Can also run gnuton `rc` action if compatible.

## Tested / verified

Not yet.

## Risks / notes

Leak if rules not applied early; Router-mode only.

## Links / sources

- `Changelog-NG.txt (3004.388.8 killswitch)`
