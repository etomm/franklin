# MAC filter

**Category:** Wireless  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Allow/deny wireless or wired clients by MAC address.

## How gnuton implements it

Stock `rc` generates hostapd ACLs/`ebtables` rules from the MAC list.

## Requirements

Stock hostapd/ebtables.

## Franklin approach

Stock handles it; nothing to port.

## Tested / verified

Stock MAC filter UI present.

## Risks / notes

Not a security boundary on its own (MAC spoofing); keep stock implementation.

## Why this kind (evidence)

stock: `ebtables` exists in both rootfs and the filter is configured from the stock wireless pages (no gnuton-only page/binary).

## Links / sources

- (none yet)
