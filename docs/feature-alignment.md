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

**#3 `menuTree.js` — PATCH (delete one line).**
Removes the AP-mode exclusion of the Traffic Analyzer section so the Traffic
Monitor tabs are reachable. This is a **product decision**, not a defect fix.
Direction: keep it explicit and documented as a Franklin UI policy, or drop the
exposure.

**#4 `WiFi_Insight.asp` — SUBSTITUTED.**
gnuton ships a stub whose linked sub-pages (`visindex.asp`, `metrics.asp`,
`channelcapacity.asp`, `configure.asp`) exist nowhere in its firmware. The MIT
addon is used instead, and it manages its own menu entry (`menuTree.js` edit).
This is a deliberate substitute for a broken vendor artifact, not a patch of
one.

**#5 Traffic Monitor pages — REPLACED.**
`Main_TrafficMonitor_last24/daily/monthly.asp` are our pages reading our sqlite
data. The vendor pages are fine; only their data source (`/update.cgi`) is not
fed on an AP node.
Direction (textbook franklin-rc workaround): keep the vendor pages, and
produce the `/update.cgi` output they expect from our collector — a handler
served from the shim/companion instead of a page takeover.

## Priority

1. **#5** — largest deviation, cleanest fix (feed `/update.cgi`, delete our page).
2. **#1/#2** — converge on the XT9 `httpd` build; both are handler defects.
3. **#3/#4** — document as deliberate policy/substitution; no code change.
