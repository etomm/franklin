# Traffic Analyzer / bandwidth monitor

**Category:** Monitoring  
**Modes:** Router  
**Status:** `out-of-scope`  
**Kind:** proprietary  
**Required:** no  
**Upstream:** stock ASUS (proprietary DPI)

## Dependencies

- [adaptive-qos](adaptive-qos.md)

## Build / install (separable)

Nothing to build: closed/licensed component. Stock keeps providing it.

## What it does

Historical per-client/per-app bandwidth statistics and charts.

## How gnuton implements it

Stock ASUS Traffic Analyzer page fed by `bwdpi`/DPI classification.

## Requirements

DPI (`BCM_DPI` + `bwdpi`) for app classification; `rstats` for per-client totals.

## Franklin approach

Per-client byte counters are feasible; per-app classification is tied to proprietary DPI. Traffic Monitor (a different, gnuton feature) covers the simple graphs.

## Tested / verified

Not tested.

## Risks / notes

App-level stats need AiProtection; keep expectations at per-interface/per-client.

## Why this kind (evidence)

stock/proprietary: `TrafficAnalyzer_Statistic.asp` exists in BOTH rootfs; the gnuton-only Traffic Monitor pages are a separate feature.

## Links / sources

- `adaptive-qos.md`
