# Franklin (FrankenMerlin) — userland extension layer for stock ASUSWRT
#
# This repository is intentionally LEAN: it contains only the userland
# extension (boot hooks, scripts, web UI, per-device profiles, installer).
# It is NOT a firmware fork and does not carry the ASUSWRT/gnuton source tree.
#
# Reference to upstream gnuton is pinned in GNUTON_REF and fetched on demand
# by tools/fetch-gnuton.sh (see docs/gnuton-feature-parity.md).

# Feature plans (one detailed plan per gnuton feature)
See [docs/features/README.md](docs/features/README.md).

## Project layout
- core/        device-agnostic boot hooks, libraries, tools
- devices/     per-model profiles (switch sequences, Entware arch, notes)
- usb/         template asusware.arm tree laid onto the USB stick
- web/         optional custom control panel (lighttpd + CGI)
- install/     one-shot installer for a target router
- docs/        hardware notes, recovery, gnuton feature-parity tracking
- tools/       helper scripts (fetch upstream reference, packaging)

## Quick start (XT9)
See docs/xt9-notes.md and install/install-franklin.sh.

## Status
Idea / research. See plans/franklin.md for the full design.
