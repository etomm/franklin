# Port forwarding / virtual server / DMZ

**Category:** Network  
**Modes:** Router  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- [firewall-custom](firewall-custom.md)

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Expose internal services on the WAN, including a DMZ host and UPnP/NAT-PMP.

## How gnuton implements it

Stock `rc` builds `iptables` DNAT rules from nvram/UPnP.

## Requirements

Stock `iptables` NAT and `miniupnpd`.

## Franklin approach

Stock handles it; Franklin firewall rules must not flush the NAT table (or must re-add forwardings).

## Tested / verified

Stock pages present; not exercised.

## Risks / notes

Router-mode only; a careless `iptables -F` breaks forwardings until restart.

## Why this kind (evidence)

stock: `Advanced_VirtualServer_Content.asp` and `miniupnpd` exist in BOTH rootfs.

## Links / sources

- `firewall-custom.md`
