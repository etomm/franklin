# Feature alignment: are we shipping gnuton's artifacts?

The rule: **ship the vendor's real artifact, with the smallest possible glue.**
If something misbehaves, assume our Frankenstein wiring first; put the workaround
in the companion (`franklin-rc` / `libfranklin_rc.so`), not in the vendor's
pages. Patched or replaced vendor pages are deviations and must be listed as
such.

Legend: **ALIGNED** = vendor artifact untouched + our start/config glue ·
**GLUE** = Franklin mechanism, no vendor artifact involved · **PATCH** =
vendor file edited · **REPLACED** = our file served under a vendor's name ·
**SUBSTITUTED** = a different project's artifact used instead of the vendor's.

## Delivered features

| feature | artifact shipped | our part | status |
|---|---|---|---|
| cake-qos | `sch_cake.ko` built from ASUS GPL sources | `start.sh` loads it, checks backends | ALIGNED |
| tee | `xt_TEE.ko` from ASUS GPL | load script | ALIGNED |
| ipset | `ip_set*.ko` + gnuton `ipset` binary | load + set bootstrap | ALIGNED |
| snmp | gnuton `snmpd` + its four net-snmp libs | config generated with gnuton rc's rules; start/stop; `restart_snmpd` handler | ALIGNED |
| networkmap | gnuton `networkmap` | bind + shm bootstrap | ALIGNED |
| wifi-clients | gnuton `wl`/driver output (no vendor page) | publishes `/www/ajax_wificlients.asp` feed | ALIGNED as a producer, but see PATCH #1 |
| wifi-insight | third-party MIT `wifiinsight` addon | installs page, advertises token, cron | SUBSTITUTED (see #4) |
| entware | none (opt-in package tree) | own bootstrap layout | GLUE (out of porting scope) |
| boot-hook | none | asusware shim → `franklin-boot` | GLUE |
| kernel-modules | none | build recipe for `.ko` | GLUE |
| overlayfs | `overlay.ko`, `exportfs.ko` from ASUS GPL | mount glue | GLUE |
| franklin-mount | none | `mount(2)` helper (busybox refuses targets on squashfs) | GLUE |
| web-ui-overlay | gnuton `httpd`, unmodified | wrapper, `LD_LIBRARY_PATH`, `LD_PRELOAD` shim hook | GLUE |
| ui-capabilities | none | `rc_support` tokens | GLUE |
| franklin-rc | none | `notify_rc` interposition + handlers | GLUE |
| test-access | none | test-only nvram toggle | GLUE (test only) |
| web-ui | gnuton httpd + 425-file `/www` delta + gnuton libs | build-time patches | PATCH (see #1–#3) |
| traffic-monitor | none (our page + sqlite collector) | replaces three vendor pages | REPLACED (see #5) |

Actionable plans for every item below: [plans/README.md](../plans/README.md) (0001 rstats history, 0002 httpd variant, 0003 vis_gui, 0004 ui policy).

## Deviations

**#1 `Main_WStatus_Content.asp` — PATCH (2 edits).**
`<% get_wl_status(); %>` removed and `GenContent()` wired to our
`window.franklinWlText`. Cause: gnuton's XT8 `httpd` mis-parses the XT9
`sta_info` layout, so the handler emits malformed JS. This is *our* ABI
mismatch (XT8 binary on XT9), not a gnuton defect.
Direction: fix the handler, not the page — i.e. the XT9 `httpd` build, or a
shim over the handler's data source.

**#2 `Advanced_System_Content.asp` — PATCH (1 edit).**
`get_all_accounts()` returns nothing on XT9 → `accounts[0]` undefined → the
change-password dialog always returned 401. Same class as #1.
Direction: the handler is compiled into `httpd` (closed); XT9 rebuild is the
real fix. Until then the fallback to `nvram http_username` is the smallest
correct patch.

**#3 `menuTree.js` — moved to its own feature (POLICY, not a patch).**
The AP-mode exclusion is a product decision; it now lives in
`features/ui-policy/` (requires `web-ui`, `web-ui-overlay`), applied at runtime
to the served tree with a saved original for `stop.sh`. No longer part of the
`web-ui` delta, and it works the same on an existing gnuton installation.

**#4 `WiFi_Insight.asp` — SUBSTITUTED, now with the real cause.**
The pages gnuton links do exist — in the XT9 GPL as Broadcom's
`.../apps/visualization/www/` (`visindex.asp`, `metrics.asp`,
`channelcapacity.asp`, `configure.asp`, …) — and the backend is
`httpd/vis_gui.c` (`json.cgi*`, `visdata.db*`). But **neither** stock XT9 nor
gnuton XT8 httpd contains the string `json.cgi`: `vis_gui` is compiled out of
both builds, and the pages' ~15 JS/CSS assets plus `visdata.db` are absent from
the GPL. So the vendor feature is incomplete in every binary we have; the MIT
addon is a substitute for a build-configuration omission, not for a missing
program. Unbroken requires httpd candidate E (see experiments/httpd-variants).

**#5 Traffic Monitor pages — REPLACED, with a vendor path identified.**
`Main_TrafficMonitor_last24/daily/monthly.asp` are our pages reading our sqlite
data. The vendor pages are fine; their data comes from `/update.cgi`, which
serves `/var/spool/rstats-history.js` written by the **stock `/bin/rstats`
daemon** (nvram `rstats_*`). rstats is present in both firmwares but is not
started in AP mode. Starting it is the intended fix; the takeover then goes
away.

## Priority

1. **#5** — start the stock `rstats` daemon, keep the vendor pages, delete our
   page takeover and the sqlite collector's published page.
2. **#1/#2** — handler defects; evaluate shim (D) vs rebuilt httpd (E) using
   `docs/experiments/httpd-variants.md`.
3. **#3** — done: `features/ui-policy/` (policy, reversible).
4. **#4** — substitute stands until an httpd with `vis_gui` exists.
