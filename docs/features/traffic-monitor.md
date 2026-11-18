# Traffic Monitor (Franklin history)

**Category:** Monitoring  
**Modes:** all  
**Status:** `implemented`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** n/a - Franklin addition (ASUS only collects on router mode)

## Dependencies

- [web-ui-overlay](web-ui-overlay.md)

## Build / install (separable)

Franklin addition: install on USB and start from the boot hook.

## What it does

Per-interface traffic history: last 24 h, daily and monthly totals.

## How gnuton implements it

Redesigned pages using Chart.js; history tabs need router-mode accounting.

## Requirements

web-ui-overlay (/www mounted); sqlite3 (stock); cru for sampling.

## Franklin approach

collects /proc/net/dev counters into sqlite3 on the USB every 5 min, publishes /www/traffic-data.asp, and serves one page under the three stock tab names (last24/daily/monthly). Stock realtime tab untouched.

## Tested / verified

On the XT9 (AP-mode node): collector writes rows for br0/eth0/eth4/eth5/eth6; published JS parses; 24 h, daily and monthly views get live data; cron re-added at boot. Stock realtime page still plots /update.cgi counters.

## Risks / notes

AP mode has no WAN accounting, so only Franklin's own collector provides history; DPI-based Traffic Analyzer tab stays hidden.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/features/traffic-monitor.md`
- `features/traffic-monitor/README.md`
