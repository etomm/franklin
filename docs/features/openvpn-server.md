# OpenVPN Server

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

Run an OpenVPN server on the router for remote clients.

## How gnuton implements it

Firmware openvpn server + cert generation; page `Advanced_VPN_OpenVPN.asp`.

## Requirements

openvpn, certs, firewall/NAT, WAN.

## Franklin approach

Stock supports it; expose gnuton page. Cert generation may be gnuton-specific.

## Tested / verified

openvpn present; page loads.

## Risks / notes

Router-mode only.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_VPN_OpenVPN.asp`
