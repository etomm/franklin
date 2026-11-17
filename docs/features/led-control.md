# LED control

**Category:** System  
**Modes:** all  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Turn LEDs on/off, brightness.

## How gnuton implements it

LED scripts/sysfs.

## Requirements

LED sysfs entries.

## Franklin approach

Scripts over sysfs; expose UI optionally.

## Tested / verified

Not yet.

## Risks / notes

Model-specific LED paths.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- (none yet)
