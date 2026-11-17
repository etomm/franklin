# WireGuard Server

**Category:** VPN  
**Modes:** Router  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)
- [firewall-custom](firewall-custom.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Run a WireGuard server on the router.

## How gnuton implements it

wireguard.ko + wg + web UI (`Advanced_WireguardServer_Content.asp`).

## Requirements

wireguard.ko, wg, keys, firewall.

## Franklin approach

Stock supports it; expose gnuton page.

## Tested / verified

Module/tool present.

## Risks / notes

Router-mode.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_WireguardServer_Content.asp`
