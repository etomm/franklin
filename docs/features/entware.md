# Entware package ecosystem

**Category:** Packages  
**Modes:** all  
**Status:** `planned`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** third-party (Entware project) - NOT gnuton

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Install Entware on USB (armv7sf-k3.2).

## What it does

opkg package manager with thousands of prebuilt binaries. This is a separate third-party project (Entware), NOT part of gnuton/Merlin and NOT distributed with it.

## How gnuton implements it

gnuton does not bundle Entware and ships no `opkg`. Merlin's docs only point users to it as an optional add-on source, installed separately on USB.

## Requirements

USB (not JFFS), `armv7sf-k3.2` repo, boot hook to set up its paths.

## Franklin approach

Franklin-specific provider. Packages that only exist there are tagged `entware-package` (smartmontools, aria2, tcpdump, ...), never `gnuton-feature`. It does NOT replace gnuton binaries (httpd, libwebapi, libovpn) nor kernel modules (built from the ASUS GPL).

## Tested / verified

Not yet installed. Verified that gnuton ships no opkg, no smartctl, no hdparm, no aria2c and no tcpdump.

## Risks / notes

Its binaries are built for its own toolchain/libc; use unset LD_LIBRARY_PATH. Cannot provide gnuton-patched binaries or kernel modules.

## Why this kind (evidence)

franklin-feature: `opkg`, `smartctl`, `aria2c` and `tcpdump` are in NEITHER rootfs, so anything requiring them is an Entware package, not gnuton.

## Links / sources

- (none yet)
