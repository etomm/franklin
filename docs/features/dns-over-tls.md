# DNS-over-TLS (DoT)

**Category:** DNS  
**Modes:** Router / AP  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [dnsmasq-custom](dnsmasq-custom.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

Configure dnsmasq DoT or run Entware stubby.

## What it does

Encrypt DNS queries to upstream resolvers using stubby/getdns or dnsmasq DoT.

## How gnuton implements it

stubby/getdns, dnsmasq integration, DoT server presets; page `Advanced_System_Content.asp`.

## Requirements

stubby/getdns (stock may have), dnsmasq, cert bundle.

## Franklin approach

Use Entware stubby/unbound or stock dnsmasq DoT; expose UI.

## Tested / verified

Not yet.

## Risks / notes

dnsmasq version support; IPv6 DoT blocking fixes in gnuton are userland/kernel mix.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_System_Content.asp`
