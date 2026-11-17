# Media server (minidlna)

**Category:** Storage  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS (minidlna)

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

DLNA/UPnP media server for TVs and consoles, indexing media on USB storage.

## How gnuton implements it

Stock `minidlna` daemon + `rc` management.

## Requirements

Stock `minidlna` (`/usr/sbin/minidlna`).

## Franklin approach

Stock handles it; Franklin only needs to not break its config/DB paths.

## Tested / verified

`/usr/sbin/minidlna` present on stock.

## Risks / notes

Indexing a large library is slow and I/O heavy on USB.

## Why this kind (evidence)

stock: `usr/sbin/minidlna` exists in BOTH rootfs.

## Links / sources

- (none yet)
