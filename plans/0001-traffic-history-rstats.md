# 0001 — Traffic history from the stock `rstats` daemon

**Status:** ready · **Fixes:** alignment #5 (page takeover) · **Depends on:** nothing

## Why

Franklin replaced `Main_TrafficMonitor_last24/daily/monthly.asp` with its own
pages and a sqlite collector. That violates the rule: the vendor pages are fine,
their data source is not started.

Evidence (XT9 GPL + firmware):

```
httpd/web.c   { "update.cgi*", … do_update_cgi … }
web.c:29042   "/var/spool/rstats-speed.js"
web.c:29046   "/var/spool/rstats-history.js"
web.c:16391   "/var/lib/misc/rstats-history.gz"
/bin/rstats   present in stock XT9 and in gnuton XT8 (22 KB)
nvram         rstats_enable=1, rstats_stime=1, rstats_offset=1 (already set)
```

`/update.cgi` serves history written by `rstats`; `rstats` is not started in AP
mode because stock `rc` only starts it for router mode. The realtime page works
today because its `/update.cgi?...arg0=speed` path is fed by the same daemon
(or falls back to live counters) — history is what is empty.

## Steps

1. **Probe the daemon** on the device (already partially done):
   ```sh
   /bin/rstats            # prints usage/history loads; run in background
   sleep 60
   ls -l /var/tmp/rstats* /var/spool/rstats*
   ```
   Determine: does `rstats` write `/var/tmp/rstats-history.js` and does
   `/update.cgi` serve it? If it needs `rstats_path`/interval nvram, set the
   values the vendor pages assume (24 h window).
2. **Make it a feature**, not a command:
   ```
   features/traffic-history/
     feature.yaml        kind: workaround, requires: [ui-policy]
     payload/start.sh    ensure rstats settings, start /bin/rstats, verify spool
     payload/stop.sh     kill rstats (leave history files)
   ```
   Companion action `restart_rstats` (franklin-rc handler) if the UI exposes a
   setting.
3. **Delete the takeover** once the vendor pages render:
   - `features/traffic-monitor/payload/page.asp` and the `cp` in its `start.sh`;
   - the `traffic-data.asp` publisher in `collect.sh` (keep the sqlite history
     only if a Franklin page still uses it — otherwise drop the feature);
   - remove the three `Main_TrafficMonitor_*` installs from the composition.
4. **Keep the UI exposure**: `ui-policy` stays (menu section is hidden in AP
   mode by gnuton's menuTree).
5. Update catalog + alignment docs (`feature-catalog.py`, `docs/feature-alignment.md`).

## Acceptance

- `pidof rstats` non-empty after boot, `boot.log` shows the feature start.
- `/var/spool/rstats-history.js` (or `/var/tmp/…`) grows.
- In the UI, **Traffic Analyzer → Last 24 hours / Daily / Monthly** render the
  **vendor** pages (byte size matches `opt/share/gnuton-www`, no
  `traffic-data.asp` request) with non-empty graphs after a few samples.
- `grep -c traffic-data /www/Main_TrafficMonitor_last24.asp` → 0.

## Rollback

`stop.sh` kills `rstats`; deploy the previous composition to restore our pages.
No nvram is committed by this plan beyond `rstats_*` settings (restore them if
they were changed).

## Files

`features/traffic-history/*` (new), `features/traffic-monitor/*` (delete or
reduce), `franklin.yaml`, `tools/feature-catalog.py`.
