# Guest network

**Category:** Wireless  
**Modes:** Router / AP / Mesh  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Isolated guest SSIDs with optional intranet access.

## How gnuton implements it

Stock guest network + gnuton fixes.

## Requirements

hostapd/brctl (stock).

## Franklin approach

Stock handles it; gnuton UI.

## Tested / verified

Guest network pages present.

## Risks / notes

Firmware-level mostly.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Guest_network.asp`
