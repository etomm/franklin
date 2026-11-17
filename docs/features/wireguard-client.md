# WireGuard Client

**Category:** VPN  
**Modes:** Router  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Connect to a WireGuard endpoint; route selected traffic via VPN Director.

## How gnuton implements it

Kernel `wireguard.ko` + `wg` tool + web UI.

## Requirements

`wireguard.ko` (module present on stock), `wg` tool, config.

## Franklin approach

Stock has wireguard module + wg; gnuton UI page. Note: enabling WG disables HW NAT.

## Tested / verified

wireguard.ko present on stock; `wg` binary present.

## Risks / notes

Disables hardware NAT acceleration; Router-mode.

## Links / sources

- `www/Advanced_WireguardClient_Content.asp`
- `usr/sbin/wg`
