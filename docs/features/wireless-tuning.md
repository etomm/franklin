# Wireless tuning (band steering, Smart Connect, WPS)

**Category:** Wireless  
**Modes:** all (mesh/AP)  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Radio parameters, band steering/Smart Connect, WPS, channel and width control.

## How gnuton implements it

Stock `rc` + `wl`/`nvram` radio settings; drivers handle the rest.

## Requirements

Stock wireless drivers and `wl` tooling.

## Franklin approach

Stock handles it; Franklin may read radio state via `wl` for monitoring but should not fight the drivers.

## Tested / verified

Stock wireless pages present; device is a mesh node on stock.

## Risks / notes

Driver-level; bad radio settings can drop all clients.

## Why this kind (evidence)

stock: `Advanced_Wireless_Content.asp`, `Advanced_Smart_Connect.asp`, `Advanced_WWPS_Content.asp` exist in BOTH rootfs.

## Links / sources

- (none yet)
