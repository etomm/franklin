# overlayfs modules (overlay.ko + exportfs.ko) — workaround

**Category:** Kernel  
**Modes:** all  
**Status:** `tested`  
**Kind:** workaround  
**Required:** no  
**Upstream:** n/a — Franklin workaround (CONFIG_OVERLAY_FS unset on stock)

## Dependencies

- [kernel-modules](kernel-modules.md)

## Build / install (separable)

Run features/overlayfs/build.sh -> builds exportfs.ko + overlay.ko from the ASUS GPL.

## What it does

Adds overlayfs to stock, so gnuton's pages can be layered over the stock /www instead of replacing the whole tree.

## How gnuton implements it

n/a: gnuton's kernel ships overlayfs-capable config and never needs it for the UI, because its /www is simply part of the firmware.

## Requirements

`exportfs.ko` and `overlay.ko` built from the ASUS GPL for 4.19.183.

## Franklin approach

Build both modules with the kernel-module recipe; load at boot; the web UI overlay uses a lowerdir stack (gnuton tree over stock) with the upper on USB.

## Tested / verified

Built from the ASUS GPL (121 KB + 7.6 KB) and verified on the XT9: overlay over the read-only /www, copy-up on write, whiteouts, clean umount.

## Risks / notes

Stock has CONFIG_OVERLAY_FS unset, so this is an out-of-tree addition; upperdir lives on the USB and receives runtime writes.

## Why this kind (evidence)

workaround: kernel capability stock lacks (CONFIG_OVERLAY_FS not set), added the same way as cake/TEE; verified end-to-end on the device.

## Links / sources

- `docs/build-architecture.md`
- `docs/xt9-kernel-notes.md`
