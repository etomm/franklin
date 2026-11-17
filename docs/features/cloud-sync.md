# Cloud sync (Dropbox, etc.)

**Category:** Storage  
**Modes:** all  
**Status:** `out-of-scope`  
**Kind:** proprietary  
**Required:** no  
**Upstream:** stock ASUS (proprietary client)

## Dependencies

- none

## Build / install (separable)

Nothing to build: closed/licensed component. Stock keeps providing it.

## What it does

Sync USB storage folders to a cloud provider.

## How gnuton implements it

Stock ASUS Cloud Sync client (proprietary, account-bound).

## Requirements

ASUS cloud client + account service.

## Franklin approach

Proprietary client; a substitute would be Entware `rclone` as a Franklin-specific add-on, not a gnuton port.

## Tested / verified

Not tested.

## Risks / notes

Proprietary; use rclone if needed.

## Why this kind (evidence)

stock/proprietary: `cloud_sync.asp` (with Dropbox strings) exists in BOTH rootfs.

## Links / sources

- (none yet)
