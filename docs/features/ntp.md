# NTP client/server

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

Time sync and optional NTP server.

## How gnuton implements it

ntp/ntpd; `Advanced_System_Content.asp`.

## Requirements

ntpd (gnuton has ntp/ntpd; stock has ntpclient).

## Franklin approach

Use stock ntpclient or run gnuton ntpd; expose UI.

## Tested / verified

Stock uses ntpclient; gnuton has ntpd.

## Risks / notes

Low.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `usr/sbin/ntpd`
