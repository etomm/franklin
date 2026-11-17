# Disk spindown / power management

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

Spin down idle USB/attached disks and control APM/AAM to reduce noise and wear.

## How gnuton implements it

Stock `rc` handles disk spindown; the setting is on the System page.

## Requirements

Stock firmware (no extra binary needed).

## Franklin approach

Stock handles it; Franklin only needs to not keep disks awake with indexing.

## Tested / verified

`spindown` is present in `Advanced_System_Content.asp` in both stock and gnuton.

## Risks / notes

Aggressive spindown shortens some drives' life; USB bridges may ignore APM.

## Why this kind (evidence)

stock: the spindown control exists in `Advanced_System_Content.asp` in BOTH rootfs; neither ships `hdparm`.

## Links / sources

- (none yet)
