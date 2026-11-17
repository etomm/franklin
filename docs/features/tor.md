# Tor

**Category:** Services  
**Modes:** Router  
**Status:** `planned`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)
- [firewall-custom](firewall-custom.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

Route selected traffic through Tor.

## How gnuton implements it

`Tor` binary + `Advanced_TOR_Content.asp` + iptables rules.

## Requirements

`Tor` (gnuton /usr/sbin), iptables, boot hook.

## Franklin approach

Run gnuton `Tor` + redirect rules; expose page.

## Tested / verified

gnuton has `Tor`; not yet run.

## Risks / notes

Router-mode; performance; rules re-apply.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `usr/sbin/Tor`
- `www/Advanced_TOR_Content.asp`
