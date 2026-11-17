# Cake QoS

**Category:** QoS  
**Modes:** Router (WAN shaping)  
**Status:** `tested`  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [kernel-modules](kernel-modules.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

Run features/cake-qos/build.sh -> builds sch_cake.ko from the ASUS GPL.

## What it does

Modern bufferbloat-fighting qdisc (cake) for WAN traffic shaping.

## How gnuton implements it

`sch_cake.ko` + QoS UI; per-model support.

## Requirements

`sch_cake.ko` built for the exact kernel (4.19.183); tc.

## Franklin approach

Build `sch_cake.ko` from ASUS GPL, load at boot; expose UI.

## Tested / verified

Built from ASUS GPL 4.19.183; insmod + `tc qdisc add dev br0 root cake` works (no crash).

## Risks / notes

Router-mode for WAN shaping; module must match kernel; not persistent until boot hook.

## Links / sources

- `docs/xt9-kernel-notes.md`
