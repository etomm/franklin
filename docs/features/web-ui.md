# Web UI (gnuton httpd + /www)

**Category:** UI  
**Modes:** all (AP / Router / Mesh)  
**Status:** `tested`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Deploy gnuton httpd + /www + differing libs to USB; start on :8088 (see docs/xt9-kernel-notes.md).

## What it does

The gnuton/Merlin web interface: all configuration pages, menus, Traffic Monitor, Sysinfo, VPN pages, etc., served by gnuton's rebuilt httpd.

## How gnuton implements it

A rebuilt `httpd` (larger than stock, different hash) plus the full `/www` tree and its shared libraries (`libovpn`, `libshared`, `libdisk`, `libwebapi`, ...).

## Requirements

gnuton `httpd`, gnuton `/www`, all differing gnuton libs (308 files), `libovpn.so`, `libshared.so`, `libdisk.so`; `cwd=/www`; consistent `acc_num`/`acc_list`.

## Franklin approach

Bind-mount or run gnuton's httpd from USB on a separate port (:8088) serving gnuton's `/www`, with all gnuton libs in `LD_LIBRARY_PATH`. Long-term: bind-mount httpd over stock and replace `/www` (95% gnuton look/feel).

## Tested / verified

Ran gnuton httpd + www on stock XT9 on :8088; stock UI on :80 untouched; most pages 200. Fixed `acc_num=0` segfault on Advanced_System_Content.

## Risks / notes

httpd/lib ABI coupling to the ASUS kernel build; pages that call gnuton daemons may crash or show empty data; AiCloud pages intentionally unsupported.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `www/Advanced_System_Content.asp`
- `usr/sbin/httpd`
- `usr/lib/libwebapi.so`
