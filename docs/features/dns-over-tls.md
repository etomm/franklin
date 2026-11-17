# DNS-over-TLS (DoT)

**Category:** DNS  
**Modes:** Router / AP  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [dnsmasq-custom](dnsmasq-custom.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

Configure the stock `stubby` with a Franklin-managed config (no Entware).

## What it does

Encrypt DNS queries to upstream resolvers using stubby or dnsmasq DoT.

## How gnuton implements it

Configures the stock `stubby` binary and exposes DoT presets on `Advanced_System_Content.asp`.

## Requirements

`stubby` (present in BOTH stock and gnuton), dnsmasq (stock), cert bundle.

## Franklin approach

Run the stock `stubby` with a Franklin-managed config from USB/JFFS and expose the gnuton page. No Entware and no extra binary needed.

## Tested / verified

`usr/sbin/stubby` confirmed in the stock rootfs; UI wiring not tested.

## Risks / notes

dnsmasq/stubby version differences; IPv6 DoT blocking fixes in gnuton are a userland/kernel mix.

## Why this kind (evidence)

gnuton-feature (config/UI layer): `stubby` exists in BOTH rootfs, so the provider is stock; only the page/config is gnuton's — no Entware involved.

## Links / sources

- `www/Advanced_System_Content.asp`
