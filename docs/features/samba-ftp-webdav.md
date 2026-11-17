# Samba / FTP / WebDAV (stock USB apps)

**Category:** Storage  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- none

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

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

## Links / sources

- `www/Advanced_AiDisk_samba.asp`
