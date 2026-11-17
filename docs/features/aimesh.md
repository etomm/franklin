# AiMesh

**Category:** Wireless  
**Modes:** Mesh (AiMesh router/node)  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS

## Dependencies

- none

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

ASUS mesh: multiple nodes with a single SSID, seamless roaming.

## How gnuton implements it

Stock AiMesh + gnuton fixes; drivers/daemons.

## Requirements

Stock firmware (mesh coordination, drivers).

## Franklin approach

Stock handles it; don't touch drivers. gnuton has mesh config UIs.

## Tested / verified

Device is an AiMesh node; mesh works on stock.

## Risks / notes

Firmware/driver-level; not portable.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/AiMesh.asp`
