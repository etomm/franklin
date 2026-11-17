# Bridge management (brctl)

**Category:** Network  
**Modes:** all  
**Status:** `stock`  
**Kind:** stock  
**Required:** no  
**Upstream:** stock ASUS (brctl)

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Nothing to build: stock firmware provides it. Franklin only must not break it.

## What it does

Inspect/manage the soft bridges that join LAN ports, wireless interfaces and guest networks (br0, br1, ethx, wl0.x).

## How gnuton implements it

Merlin `rc` uses `brctl` for bridge add/del/list; hooks let scripts adjust bridges at boot.

## Requirements

`brctl` (stock).

## Franklin approach

Use stock `brctl` from the boot hook for extra bridges/ports; stock already manages the default bridge set.

## Tested / verified

`brctl show`/`addif`/`delif` present and working on stock.

## Risks / notes

Removing the wrong port from br0 drops connectivity; re-apply after service restart.

## Why this kind (evidence)

stock: `brctl` is in stock and no bridge page differs between stock and gnuton rootfs.

## Links / sources

- (none yet)
