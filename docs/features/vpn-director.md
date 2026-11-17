# VPN Director

**Category:** VPN  
**Modes:** Router (needs WAN + routing)  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [firewall-custom](firewall-custom.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

ip rule/ip route rules from boot hook.

## What it does

Central policy-routing UI for OpenVPN/WireGuard clients: per-source/destination rules decide which traffic goes through which VPN tunnel (replaces ad-hoc client routing).

## How gnuton implements it

Merlin `rc` + ip rules/routing tables; rules stored in JFFS; `httpd` page `Advanced_VPNDirector.asp`; helper `gettunnelip.sh`.

## Requirements

OpenVPN/WireGuard clients; iproute2 `ip rule`/`ip route`; JFFS; gnuton rc logic.

## Franklin approach

Reimplement rules with `ip rule`/`ip route` in Franklin scripts, or run gnuton's helper; no rc swap required. UI via gnuton www (bind-mounted httpd).

## Tested / verified

Not yet (Router-mode feature; device is AP).

## Risks / notes

Requires WAN/Router mode; complex policy routing; interaction with killswitch.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_VPNDirector.asp`
- `usr/sbin/gettunnelip.sh`
