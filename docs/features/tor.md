# Tor

**Category:** Services  
**Modes:** Router  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

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

## Links / sources

- `usr/sbin/Tor`
- `www/Advanced_TOR_Content.asp`
