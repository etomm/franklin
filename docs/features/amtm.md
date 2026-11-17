# amtm (terminal menu)

**Category:** Tools  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** third-party (thelonelycoder/amtm) — bundled by gnuton/Merlin, not gnuton code

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Interactive terminal menu for add-ons: it can install/manage Entware, scripts and backup jobs.

## How gnuton implements it

Ships the third-party `amtm` script (by thelonelycoder) in `/usr/sbin`. It is not a gnuton/Merlin invention and it is not an Entware package either.

## Requirements

Shell + USB. Entware is something amtm *manages*, not something it needs.

## Franklin approach

Ship the same `amtm` script from USB and run it over SSH. If Entware is absent, amtm still starts; installing Entware is one of its menu entries.

## Tested / verified

`usr/sbin/amtm` exists only in the gnuton rootfs (bundled third-party).

## Risks / notes

Assumes Merlin paths (`/jffs/scripts`, `cru`); some menu entries may need adaptation on stock.

## Why this kind (evidence)

gnuton-feature (bundled third-party): `amtm` is present ONLY in gnuton's rootfs, but it is a third-party script, not gnuton code.

## Links / sources

- `usr/sbin/amtm`
