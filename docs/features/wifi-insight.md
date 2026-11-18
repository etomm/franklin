# WiFi Insight (third-party MIT addon)

**Category:** Wireless  
**Modes:** all  
**Status:** `tested`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** third-party MIT addon (IfSugar/wifiinsight) - ASUS ships the real WiFi Insight only on its newest AI routers

## Dependencies

- [web-ui-overlay](web-ui-overlay.md)

## Build / install (separable)

Franklin addition: install on USB and start from the boot hook.

## What it does

Dashboard for the wireless environment: per-channel airtime, interference over time, neighbour sites and channel statistics.

## How gnuton implements it

gnuton only ships a leftover WiFi_Insight.asp stub: ASUS removed Wi-Fi Radar for security reasons and reserves the real WiFi Insight for its newest AI routers (GT-BE19000AI), so neither the pages nor a backend exist in our images.

## Requirements

`web-ui-overlay` (owns /www/user and menuTree.js); stock `wl` with chanim_stats; stock sqlite3 3.42; USB storage for the history database.

## Franklin approach

Franklin feature: vendors the MIT-licensed Merlin addon IfSugar/wifiinsight (with three stock patches: accept stock firmware, replace a BusyBox-incompatible tr range, ignore ubifs when picking the USB drive) and rebuilds at boot what Merlin's services-start would: page, menu entry and cron.

## Tested / verified

Installed on the XT9 with the addon's own installer after the patches: all health checks pass, first scans measured 13/8/11 channels with 10/4/4 networks, history on USB in ext4. Page and cron are RAM-based, hence the boot hook.

## Risks / notes

Third-party script running as root; MIT and auditable (LICENSE vendored). History DB on USB only.

## Why this kind (evidence)

franklin-feature: the MIT addon is the only working implementation; measured that neither stock nor gnuton ships the ASUS pages or backend (files and binary strings checked in both, plus a GT-AX6000 donor image).

## Links / sources

- `LICENSE`
- `https://github.com/IfSugar/wifiinsight`
