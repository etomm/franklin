# NVRAM tools / config export

**Category:** System  
**Modes:** all  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

Dump/restore nvram, export/import settings.

## How gnuton implements it

nvram tooling + Settings backup/restore pages.

## Requirements

`nvram` (stock), JFFS/USB.

## Franklin approach

Use stock nvram + gnuton backup pages; careful with unsupported vars.

## Tested / verified

nvram present; some vars not settable/persisted (jffs2_scripts).

## Risks / notes

nvram var support varies; don't rely on unsupported vars.

## Links / sources

- (none yet)
