# Firmware upgrade helpers

**Category:** System  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS (gnuton only changes the update channel)

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Check for and apply ASUS firmware updates, plus the upgrade UI.

## How gnuton implements it

Stock `webs_upgrade`/`rc` path; gnuton only changes the update source (`sbin/firmware_webs_update` is gnuton-only).

## Requirements

Stock upgrade tooling, signed images.

## Franklin approach

Must stay stock: Franklin must never interfere with the upgrade path or it can brick the device. Document compatibility per firmware version instead.

## Tested / verified

Stock upgrade path untouched by Franklin.

## Risks / notes

Never modify the upgrade flow; overrides must be re-applied after each upgrade.

## Why this kind (evidence)

stock: `Advanced_FirmwareUpgrade_Content.asp` exists in both rootfs; the only gnuton difference is its own update-channel script.

## Links / sources

- (none yet)
