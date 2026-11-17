# Samba / FTP / WebDAV (stock USB apps)

**Category:** Storage  
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

File sharing over SMB/FTP/WebDAV from USB storage.

## How gnuton implements it

Stock USB apps + gnuton fixes; `smbd`/`nmbd`, `vsftpd`/`ftpd`, WebDAV.

## Requirements

Stock daemons present (`smbd`, `nmbd`).

## Franklin approach

Stock handles it; gnuton pages for config. No porting needed.

## Tested / verified

smbd/nmbd present on stock; pages present.

## Risks / notes

Firmware-level; keep stock.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_AiDisk_samba.asp`
