# OpenVPN Client

**Category:** VPN  
**Modes:** Router (WAN + VPN client)  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Connect the router (or selected clients via VPN Director) to an OpenVPN server.

## How gnuton implements it

Firmware VPN daemon (`openvpn`), web page `Advanced_OpenVPNClient_Content.asp`, routing via VPN Director.

## Requirements

`openvpn` binary (present on stock), certs/configs in JFFS, routing rules.

## Franklin approach

Stock already has openvpn; expose gnuton's client page via bind-mounted httpd, or run gnuton's openvpn with generated configs.

## Tested / verified

openvpn binary present on stock; page loads via gnuton UI.

## Risks / notes

Routing/killswitch logic lives in rc; VPN page may depend on rc helpers.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_OpenVPNClient_Content.asp`
- `usr/sbin/openvpn`
