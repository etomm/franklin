# NTP client/server

**Category:** System  
**Modes:** all  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `usr/sbin/ntpd`
