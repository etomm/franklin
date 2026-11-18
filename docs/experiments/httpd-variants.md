# Experiment: which httpd should Franklin ship?

Open question behind alignment issues #1/#2 (and the WiFi Insight stub). Today we
run **gnuton's XT8 httpd** on an XT9. Its ASP/handler layer mis-parses XT9
driver data (`get_wl_status`, `sta_info`), returns nothing for
`get_all_accounts()`, and neither build compiles the `json.cgi`/`vis_gui`
backend that WiFi Insight needs.

Candidates:

| # | httpd | www / libs | expected |
|---|---|---|---|
| A | stock XT9 (`/usr/sbin/httpd`) | stock www | baseline: ASUS pages only, no gnuton menu |
| B | stock XT9 + gnuton `/www` delta | gnuton pages | gnuton ASP calls missing → pages partially dead |
| C | gnuton XT8 (today) | gnuton pages | menu works, XT9 handler data broken |
| D | gnuton XT8 + shims (`libfranklin.so` hooking handler inputs) | gnuton pages | handler data repaired without rebuilding httpd |
| E | gnuton rebuilt with XT9 blobs/config (`RTCONFIG_*` of XT9, XT9 `libwlcsm`) | gnuton pages | the real fix, but a full buildroot build |

## Tests and pass criteria

Run each candidate on a throwaway port (`8089`) with the same `/www` tree; never
on `:80` while testing.

1. **Wireless log** (`Main_WStatus_Content.asp`)
   pass: page loads without a JS SyntaxError, table has MAC/RSSI/rate for the
   associated stations.
2. **System page** (`Advanced_System_Content.asp`)
   pass: `var accounts = ["admin"];` is rendered (no fallback patch needed).
3. **SNMP page apply** (`Advanced_SNMP_Content.asp`)
   pass: `restart_snmpd` reaches the companion and the agent restarts.
4. **WiFi Insight** (`visindex.asp` + friends)
   pass: `/json.cgi?Req=...` answers and the pages draw.
5. **Traffic Monitor history** (vendor pages)
   pass: `/update.cgi` returns history after `rstats` runs.

Record per candidate: page bytes, console errors, handler output, and which
patch (if any) is still required.

## What we know already

- **C** fails 1, 2, 4.
- **B** cannot pass 1/2/4 either: the ASP handlers live in httpd, not in `/www`.
- **D** is plausible for 1/2: both failures come from data the handler receives
  through imported functions (`libwlcsm`, `libnvram`, driver ioctls), all
  hookable with the same `LD_PRELOAD` mechanism already used for `notify_rc`.
- **E** is the only option for 4 (`vis_gui.c` is compiled out of *both* builds;
  its www assets are also absent from the GPL), and it would also settle 1/2.
- **5** has a vendor path: stock ships `/bin/rstats` (the daemon behind
  `/update.cgi` → `/var/spool/rstats-history.js`). Starting it in AP mode is the
  intended fix; no page replacement needed.

## Order

1. Try **5** (cheap, vendor daemon) → then delete our page takeover.
2. Try **D** for `get_all_accounts` / `get_wl_status`: identify the imported
   function each handler consults (start from `libwlcsm` exports) and hook it in
   the shim.
3. Only then evaluate **E**, which is the strategic build project.
