# DDNS (custom providers)

**Category:** Network  
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

Dynamic DNS updates, including custom providers.

## How gnuton implements it

Stock `inadyn` plus gnuton's `sbin/ddns_custom_updated` helper and the `Advanced_ASUSDDNS_Content.asp` page.

## Requirements

`inadyn` (stock), WAN, provider credentials.

## Franklin approach

Stock DDNS covers ASUS + provider list; add custom providers with gnuton's helper (gnuton-only binary) from the boot hook. No Entware needed.

## Tested / verified

`inadyn` present in BOTH rootfs; `ddns_custom_updated` is gnuton-only.

## Risks / notes

Router-mode only; credentials on USB/JFFS with tight permissions.

## Why this kind (evidence)

stock + gnuton delta: `inadyn` is in BOTH rootfs (stock DDNS works); only `ddns_custom_updated` is gnuton-only, so custom providers are the delta.

## Links / sources

- `www/Advanced_ASUSDDNS_Content.asp`
