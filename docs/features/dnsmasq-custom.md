# Custom dnsmasq config

**Category:** DNS  
**Modes:** Router / AP  
**Status:** `stock+`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Add /jffs or Entware dnsmasq config (verify stock path).

## What it does

Add custom dnsmasq options (hosts, upstreams, DHCP options).

## How gnuton implements it

dnsmasq + `/jffs/configs/dnsmasq.conf.add`; web field.

## Requirements

dnsmasq (stock), writable JFFS.

## Franklin approach

Stock supports `/jffs/configs/dnsmasq.conf.add` (verify); otherwise start Entware dnsmasq.

## Tested / verified

dnsmasq present on stock; JFFS config path to verify.

## Risks / notes

Stock may not read `/jffs/configs` (Merlin feature) — verify.

## Links / sources

- `usr/sbin/dnsmasq`
