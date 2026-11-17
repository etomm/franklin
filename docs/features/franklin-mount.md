# franklin-mount (mount(2) helper) — workaround

**Category:** System  
**Modes:** all  
**Status:** `tested`  
**Kind:** workaround  
**Required:** no  
**Upstream:** n/a — Franklin workaround (ASUS busybox mount refuses rootfs targets)

## Dependencies

- none

## Build / install (separable)

Run features/franklin-mount/build.sh (static ARM binary via cross compiler).

## What it does

A ~20 line static binary that performs mount(2)/umount(2) directly, used to mount over paths on the read-only squashfs root.

## How gnuton implements it

n/a: gnuton ships its own httpd in the image, so it never has to mount over the stock rootfs.

## Requirements

Cross compiler at build time (arm-linux-gnueabi-gcc); nothing at runtime.

## Franklin approach

Workaround for an ASUS restriction: busybox `mount` rejects any target on the read-only squashfs (/www, /usr/sbin/httpd) with "Invalid mount path". The kernel allows it; this helper proves it.

## Tested / verified

Verified on the XT9: bind over /www, bind over /usr/sbin/httpd, and the full overlay + bind chain, each umounted back to stock.

## Risks / notes

Static ARM binary; must be rebuilt with the same cross compiler. Only used for mounts Franklin owns.

## Why this kind (evidence)

workaround: needed because the stock mount tool refuses rootfs targets; the kernel accepts them (tested).

## Links / sources

- `docs/build-architecture.md`
