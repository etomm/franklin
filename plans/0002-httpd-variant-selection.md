# 0002 — Choose the httpd variant (and drop the page patches)

**Status:** ready · **Fixes:** alignment #1 (`get_wl_status`), #2 (`get_all_accounts`) ·
**Unblocks:** 0003

## Why

Two vendor pages are patched because gnuton's **XT8 httpd** cannot serve their
handlers on the XT9:

| page | handler | symptom |
|---|---|---|
| `Main_WStatus_Content.asp` | `get_wl_status()`, `wl_log.asp` | malformed JS (`,"-42",AU"]`) → SyntaxError |
| `Advanced_System_Content.asp` | `get_all_accounts()` | renders `var accounts = [[]][0]` → chpass 401 |

Both handlers receive their data through **imported** symbols
(`libwlcsm`, `libnvram`, driver ioctls), which is exactly the surface
`libfranklin_rc.so` already interposes for `notify_rc`.

Candidates and pass criteria live in `docs/experiments/httpd-variants.md`.

## Steps

### A. Measure the current baseline (already known, record it)

1. On `:8089` (throwaway) with the gnuton tree, fetch both pages and store:
   ```
   /Main_WStatus_Content.asp   → look for the malformed `sta_info` fragment
   /Advanced_System_Content.asp → var accounts line
   ```
2. Record page bytes, console errors (browser), and which patch is needed.

### B. Shim experiment (variant D) — cheapest

1. Find what the handlers consult:
   ```sh
   nm -D firmware/gnuton-xt8/rootfs/usr/lib/libwlcsm.so | head -40
   nm -D firmware/gnuton-xt8/rootfs/usr/sbin/httpd | grep ' U '
   strings firmware/gnuton-xt8/rootfs/usr/sbin/httpd | grep -i 'sta_info\|assoclist'
   ```
2. Write a diagnostic `LD_PRELOAD` shim (pattern: `features/franklin-rc/src/shim.c`)
   that logs the calls made while fetching the two pages. Start the throwaway
   httpd with it:
   ```sh
   LD_LIBRARY_PATH=…/opt/lib/gnuton LD_PRELOAD=/tmp/probe.so \
     …/opt/bin/gnuton-httpd -p 8089
   ```
3. Identify the single function whose output the handler mis-reads; reimplement
   its return value in the shim (XT9 layout), keeping the vendor page untouched.
4. If both handlers can be repaired this way → **variant D wins**:
   - move the work into a permanent shim (`libfranklin_ui.so` or an addition to
     `libfranklin_rc.so`), loaded by the existing httpd wrapper;
   - delete the two `sed` blocks from `features/web-ui/build.sh`;
   - acceptance: vendor pages render with no patch.
5. If the handler logic is compiled in (not reachable through imports) → variant
   D fails; continue to C.

### C. Rebuild decision (variant E)

1. Locate the matching gnuton commit for `3004.388_24854` (XT8 tree) and the
   XT9 `RTCONFIG_*`/`libwlcsm` blob set.
2. Build with gnuton's Docker builder; compare `httpd` symbol imports against the
   shipped libraries (`docs/library-overrides.md` rule).
3. Acceptance is the same page tests plus no regression in the pages listed in
   the experiment doc.

## Acceptance (either variant)

- `grep -c 'get_wl_status' features/web-ui/build.sh` → 0 and
  `grep -c 'get_all_accounts' features/web-ui/build.sh` → 0.
- Wireless log renders rows (MAC / RSSI / rate) with **no** JS console error.
- System page renders `var accounts = ["admin"];` from the vendor handler.
- Both survive a reboot and a fresh browser (Ctrl+F5).

## Rollback

Remove the shim from the wrapper (`web-ui-overlay/start.sh`) and restore the two
patches; the patches are harmless and documented.

## Files

`features/web-ui/build.sh`, the httpd wrapper in
`features/web-ui-overlay/payload/start.sh`, a new shim under
`features/franklin-rc/src/` (or a new feature), `docs/library-overrides.md`,
`docs/feature-alignment.md`.
