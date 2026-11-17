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

gnuton does not bundle Entware. Merlin's docs only point users to it as an optional add-on source; it is installed separately on a USB stick.

## Requirements

USB (not JFFS), `armv7sf-k3.2` repo.

## Franklin approach

Optional provider/enabler: use Entware for generic tools (cron, smartmontools, stubby, aria2, snmpd, nfs, ...). It does NOT replace gnuton-specific binaries (httpd, libwebapi/libovpn, ...) nor kernel modules (those must be built from the ASUS GPL).

## Tested / verified

Not yet installed.

## Risks / notes

Its binaries are built for its own toolchain/libc; use unset LD_LIBRARY_PATH. Cannot provide gnuton-patched binaries or kernel modules.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- (none yet)
