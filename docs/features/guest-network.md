# Guest network

**Category:** Wireless  
**Modes:** Router / AP / Mesh  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- none

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

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

## Links / sources

- `www/Guest_network.asp`
