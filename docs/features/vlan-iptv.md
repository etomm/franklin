# VLAN / IPTV port tagging (ethswctl, softswitch)

**Category:** Network  
**Modes:** Router / AP (wired switch config)  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Per-port VLAN tagging and softswitch map: ISP IPTV on one port, internet on another, and VLAN segmentation of the wired switch.

## How gnuton implements it

Merlin `rc` programs the switch map through `ethswctl`/softswitch helpers; the gnuton/Merlin UI exposes it as VLAN/IPTV config.

## Requirements

`ethswctl` (present in stock too), switch driver support; wired ports only.

## Franklin approach

Drive `ethswctl` from the USB boot hook (sequence verified on the XT9); no rc swap needed.

## Tested / verified

Sequence verified on XT9; not yet wired to boot.

## Risks / notes

Switch map is model-specific; a wrong map can cut off LAN/WAN access. Wireless clients are unaffected by VLAN tagging.

## Why this kind (evidence)

gnuton-feature: no VLAN/IPTV page in either rootfs, but Merlin `rc` + `ethswctl` implement it; stock exposes no UI, so Franklin scripts it.

## Links / sources

- `docs/xt9-notes.md`
