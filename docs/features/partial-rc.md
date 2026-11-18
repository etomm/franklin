# partial rc (capability advertisement) — workaround

**Category:** System  
**Modes:** all  
**Status:** `tested`  
**Kind:** workaround  
**Required:** no  
**Upstream:** n/a — Franklin workaround (stock rc advertises fewer capabilities than gnuton)

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Franklin workaround: deploy from USB/boot hook (see Franklin approach).

## What it does

Tells the gnuton UI which capabilities exist, by appending tokens to nvram `rc_support` that stock XT9 does not advertise.

## How gnuton implements it

gnuton's rc advertises more capabilities; the UI's menuTree.js hides pages when httpd's get_ui_support() reports no flag for them.

## Requirements

`boot-hook`. Runtime-only nvram change (no commit).

## Franklin approach

Appends the tokens for capabilities Franklin really provides to nvram `rc_support` at boot (`nwtool usbX cake snmp`) and restores the saved original on stop. It is only the capability advertisement: the data producers behind those pages are separate features (wifi-clients, traffic-monitor), not a reimplementation of rc.

## Tested / verified

Verified on the XT9: tokens are absent from stock's rc_support and the hook sets them at runtime. `wifiradar` was retired after checking that gnuton ships WiFi_Insight.asp but none of the pages it links to (visindex.asp, metrics.asp, channelcapacity.asp, configure.asp) exist in its firmware or its httpd.

## Risks / notes

Advertising a capability whose backend is missing would show a page that cannot work, so only tokens Franklin really provides are added.

## Why this kind (evidence)

workaround: stock rc_support lacks wifiradar/nfsd/nwtool/usbX/cake, which is why gnuton-only menus are filtered out (menuTree.exclude).

## Links / sources

- `docs/build-architecture.md`
