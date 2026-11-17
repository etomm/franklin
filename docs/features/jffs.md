# JFFS partition

**Category:** Storage  
**Modes:** all  
**Status:** `stock`  
**Required:** yes  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- none

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Persistent writable storage for configs/scripts.

## How gnuton implements it

JFFS enabled; scripts/configs stored there.

## Requirements

Stock JFFS (present).

## Franklin approach

Use `/jffs` for Franklin configs/logs (stock).

## Tested / verified

JFFS present and writable.

## Risks / notes

None.

## Links / sources

- (none yet)
