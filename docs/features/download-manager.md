# Download manager (aria2)

**Category:** Storage  
**Modes:** all  
**Status:** `planned`  
**Kind:** entware-package  
**Required:** no  
**Upstream:** n/a - Entware package (aria2); gnuton ships none

## Dependencies

- [entware](entware.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

`opkg install aria2` (Entware), then supervise it from the boot hook.

## What it does

Background HTTP/FTP/BitTorrent downloads to attached storage.

## How gnuton implements it

Not bundled: gnuton ships no `aria2`; users install it (usually from Entware).

## Requirements

`aria2` binary (Entware), storage, boot hook to start it.

## Franklin approach

Franklin addition: install aria2 (Entware) and supervise it from the boot hook. Not a gnuton port.

## Tested / verified

Not yet.

## Risks / notes

Third-party binary; watch write wear and permissions on the share.

## Why this kind (evidence)

franklin-feature: no `aria2` in the gnuton rootfs (checked `usr/bin`, `usr/sbin`, `bin`, `sbin`).

## Links / sources

- (none yet)
