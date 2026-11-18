# wifi-clients (wireless station feed) — workaround

**Category:** Monitoring  
**Modes:** all  
**Status:** `tested`  
**Kind:** workaround  
**Required:** no  
**Upstream:** n/a — Franklin workaround (gnuton httpd is an XT8 build; its sta_info parsing breaks on XT9)

## Dependencies

- [web-ui-overlay](web-ui-overlay.md)

## Build / install (separable)

Franklin workaround: deploy from USB/boot hook (see Franklin approach).

## What it does

Publishes the wireless client arrays the gnuton wireless-log page expects, from the vendor `wl` tool.

## How gnuton implements it

gnuton's httpd answers `<% get_wl_status(); %>` from its own handler, which reads `sta_info` through the XT8 struct layout.

## Requirements

`web-ui-overlay` (the page must be served from a writable /www) and the stock `wl` tool.

## Franklin approach

Companion job in the franklin_rc spirit: instead of emulating rc, it asks the driver for the same data and writes `/www/franklin-wifi.js`; the page includes that file in place of the broken handler.

## Tested / verified

Verified on the XT9: feed generated from real clients (assoclist + sta_info + ARP), page patched to include it.

## Risks / notes

Field mapping follows the page's JS (mac, ip, name, rssi, rx/tx, time, phy, flags); if gnuton changes that page the feed must follow.

## Why this kind (evidence)

workaround: the XT8-built httpd emits an unquoted flags field (missing opening quote) because sta->flags is read at the wrong offset on XT9.

## Links / sources

- `docs/build-architecture.md`
