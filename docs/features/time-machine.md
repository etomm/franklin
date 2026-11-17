# Time Machine (AFP) backup

**Category:** Storage  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- [samba-ftp-webdav](samba-ftp-webdav.md)

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

macOS Time Machine backups to a shared disk (AFP or SMB).

## How gnuton implements it

Stock `netatalk`/SMB support configured by `rc`.

## Requirements

Stock AFP/SMB support and a writable share.

## Franklin approach

Stock handles it; ensure Franklin does not alter share permissions or the backup sparsebundle path.

## Tested / verified

`Advanced_TimeMachine.asp` present on stock.

## Risks / notes

AFP is deprecated by Apple in favour of SMB; disk space grows quickly.

## Why this kind (evidence)

stock: `Advanced_TimeMachine.asp` exists in BOTH rootfs.

## Links / sources

- (none yet)
