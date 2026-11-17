# DDNS (custom providers)

**Category:** Network  
**Modes:** Router  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Dynamic DNS updates, incl. custom providers.

## How gnuton implements it

inadyn/ddns-scripts; `Advanced_ASUSDDNS_Content.asp`.

## Requirements

DDNS client (inadyn/Entware), WAN.

## Franklin approach

Stock DDNS or Entware ddns-scripts; gnuton page.

## Tested / verified

ASUS DDNS page present.

## Risks / notes

Router-mode.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_ASUSDDNS_Content.asp`
