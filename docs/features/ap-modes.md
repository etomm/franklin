# AP / Bridge / Repeater / Media bridge modes

**Category:** Wireless  
**Modes:** AP / Router / Mesh  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Operating modes of the box: wireless router, access point, repeater, media bridge.

## How gnuton implements it

Stock `rc` + `nvram` mode variables; drivers do the work.

## Requirements

Stock firmware and wireless drivers.

## Franklin approach

Stock handles it; Franklin must not break mode switching and should detect AP mode (many features need Router mode).

## Tested / verified

Device runs as an AiMesh node in AP mode on stock.

## Risks / notes

Franklin features that need WAN/DHCP/firewall do not work in AP mode.

## Why this kind (evidence)

stock: `Advanced_OperationMode_Content.asp` is byte-for-byte present in both rootfs and mentions repeater/bridge/media.

## Links / sources

- `docs/xt9-notes.md`
