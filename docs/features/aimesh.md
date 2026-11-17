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

ASUS mesh: multiple nodes with a single SSID, seamless roaming, and a controller that pushes configuration to every node.

## How gnuton implements it

Stock AiMesh only: gnuton ships the same closed mesh stack (amas*, cfg_server/cfg_client, bsd, dhd.ko) and adds nothing to it.

## Requirements

Stock firmware: mesh agent, config-sync daemons and wireless drivers. Nothing Franklin can build or replace.

## Franklin approach

Stock handles it and Franklin must stay out of the way: no patching of amas/cfg_server, no nvram-only state, and no touching build/version identity. On a node, settings are owned by the controller.

## Tested / verified

Device is an AiMesh node in AP mode on stock; mesh works. Both rootfs contain identical mesh components, so there is no gnuton delta to port.

## Risks / notes

Firmware/control-plane level, not portable. Config pushed by cfg_server can overwrite anything Franklin sets in nvram. All nodes must run the same build — see docs/mesh-and-firmware-compatibility.md.

## Why this kind (evidence)

stock: `amas*`, `cfg_server`, `cfg_client`, `bsd`, `dhd.ko` and the AiMesh pages exist in BOTH rootfs; no gnuton-only mesh file was found by tools/parity-audit.py.

## Links / sources

- `docs/mesh-and-firmware-compatibility.md`
- `docs/parity-audit.md`
