# IPv6 (native, 6in4, 6to4, 6rd)

**Category:** Network  
**Modes:** Router  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

IPv6 connectivity and addressing for the LAN.

## How gnuton implements it

Stock IPv6 stack (`odhcp6c`, IPv6 firewall) + gnuton fixes.

## Requirements

Stock kernel IPv6 (built-in) and userspace.

## Franklin approach

Stock handles it; Franklin firewall/QoS rules must be kept IPv4/IPv6 symmetric where relevant.

## Tested / verified

IPv6 present on stock; AP mode inherits from the main router.

## Risks / notes

Router-mode for prefix delegation; IPv6 firewall rules easy to get wrong.

## Why this kind (evidence)

stock: `Advanced_IPv6_Content.asp`, `Advanced_IPv61_Content.asp`, `Main_IPV6Status_Content.asp` and `odhcp6c` exist in BOTH rootfs.

## Links / sources

- (none yet)
