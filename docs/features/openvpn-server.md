# OpenVPN Server

**Category:** VPN  
**Modes:** Router  
**Status:** `stock+`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `www/Advanced_VPN_OpenVPN.asp`
