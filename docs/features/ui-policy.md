# UI policy (what Franklin exposes in AP-mode UI)

**Category:** System  
**Modes:** all  
**Status:** `implemented`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [web-ui](web-ui.md)
- [web-ui-overlay](web-ui-overlay.md)

## Build / install (separable)

Franklin addition: install on USB and start from the boot hook.

## What it does

Deliberate, reversible changes to what the gnuton UI shows on this node.

## How gnuton implements it

gnuton's menuTree hides router-only sections when sw_mode=3 (AP mode).

## Requirements

`web-ui`, `web-ui-overlay` (the served /www tree).

## Franklin approach

Applies the policy at runtime to the served /www, keeping a pristine copy for stop.sh: today it unhides the Traffic Analyzer section so the Traffic Monitor tabs are reachable on a node. Kept out of web-ui/build.sh because it is a product decision, not a vendor-file fix; also applies to an existing gnuton installation, not just Franklin's delta.

## Tested / verified

On the XT9: section appears after start, original menuTree.js restored by stop; the file is the served (overlaid) one, so the change survives without a rebuild.

## Risks / notes

A policy is not a fix: if gnuton's AP rationale matters (WAN accounting), the exposed pages will show empty data unless a producer exists.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/feature-alignment.md`
- `features/ui-policy/README.md`
