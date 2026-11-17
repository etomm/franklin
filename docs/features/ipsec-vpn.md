# IPSec VPN

**Category:** VPN  
**Modes:** Router  
**Status:** `stock+`  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)
- [firewall-custom](firewall-custom.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

IPSec server (strongSwan) for site-to-site / remote clients.

## How gnuton implements it

strongswan + web UI (`Advanced_VPN_IPSec.asp`).

## Requirements

strongswan (stock), certs/PSK, firewall.

## Franklin approach

Stock supports it; expose gnuton page.

## Tested / verified

IPSec pages present on stock.

## Risks / notes

Router-mode.

## Links / sources

- `www/Advanced_VPN_IPSec.asp`
