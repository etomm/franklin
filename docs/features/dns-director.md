# DNS Director (DNSFilter)

**Category:** DNS  
**Modes:** Router (DHCP/DNS server)  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [firewall-custom](firewall-custom.md)
- [dnsmasq-custom](dnsmasq-custom.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

iptables REDIRECT + dnsmasq config from boot hook.

## What it does

Per-client DNS redirection/filtering: force clients to specific DNS servers (or block) via iptables REDIRECT + dnsmasq.

## How gnuton implements it

Merlin/gnuton `rc` + iptables REDIRECT (v4/v6) + dnsmasq; page `DNSDirector.asp`.

## Requirements

iptables, dnsmasq, client list; Router mode.

## Franklin approach

Reimplement iptables REDIRECT rules + dnsmasq config in Franklin scripts; gnuton UI page.

## Tested / verified

Not yet (Router-mode).

## Risks / notes

AP mode has no local DHCP/DNS; depends on upstream.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/DNSDirector.asp`
