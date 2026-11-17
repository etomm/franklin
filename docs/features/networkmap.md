# Network Map / client list

**Category:** Monitoring  
**Modes:** all  
**Status:** `tested`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

Connected clients (wired/wireless), names, IPs, mesh topology.

## How gnuton implements it

`networkmap` daemon + httpd page `index.asp`/`device-map`.

## Requirements

networkmap daemon; correct shm size (gnuton expects 198168 vs stock 197916).

## Franklin approach

Run gnuton networkmap (creates larger shm) or fix shm; gnuton UI reads it.

## Tested / verified

Fixed shm size mismatch; `nmp_cache.js` populated; gnuton UI lists clients.

## Risks / notes

Dual networkmap (watchdog) when swapping; shm size coupling.

## Links / sources

- `docs/firmware-comparison.md`
