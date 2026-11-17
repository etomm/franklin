# amtm (terminal menu)

**Category:** Tools  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [entware](entware.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Interactive terminal menu for add-ons (Entware, scripts, backups).

## How gnuton implements it

`amtm` binary/script; installs/manages Entware and add-ons.

## Requirements

Entware, shell, USB.

## Franklin approach

Run gnuton `amtm` or a Franklin equivalent; expose via SSH.

## Tested / verified

gnuton has `amtm`.

## Risks / notes

Designed for Merlin paths; may need adaptation.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `usr/sbin/amtm`
