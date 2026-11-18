# traffic-monitor

Traffic history for the Traffic Analyzer → Traffic Monitor tabs, filled by
Franklin because the stock accounting only runs in router mode.

## Why this exists

In AP mode (this XT9 is an AiMesh node, `sw_mode=3`) ASUS:

* hides the `menu_TrafficAnalyzer` section, and
* never runs the traffic accounting behind the history tabs.

The pages themselves work: `Main_TrafficMonitor_realtime.asp` reads interface
counters from `/update.cgi`, which is why it draws live graphs even on a node.
`menuTree.js` in the web-ui delta drops the AP-mode exclusion so the section is
visible; this feature supplies the history the other tabs ask for.

## What it ships

```
payload/collect.sh   sample /proc/net/dev -> sqlite, publish /www/traffic-data.asp
payload/page.asp     one page, installed under three stock tab names
payload/start.sh     install pages, first sample, add the cron entry
payload/stop.sh      remove pages + cron, keep the database
```

Data lives on the stick, not in tmpfs:

```
/tmp/mnt/FRANKLIN/traffic-monitor/traffic.db      sqlite, 13 months retained
/tmp/mnt/FRANKLIN/traffic-monitor/last-counters   previous counters for deltas
```

`/www/traffic-data.asp` is a JS include (no ASP code) carrying:

```js
TM.ifaces[ifname] = [[tsSec, inBps, outBps], ...]      last 24 h, 5-min samples
TM.days[ifname]   = [["YYYY-MM-DD", inBytes, outBytes], ...]
TM.months[ifname] = [["YYYY-MM", inBytes, outBytes], ...]
```

## Interface selection

`TRAFFIC_IFACES` (default `br0 eth0 eth4 eth5 eth6`) is what `/proc/net/dev`
shows on this model: the bridge, the uplink and the per-radio BSS interfaces.
Counters are sampled as deltas, so a reboot or an interface re-created under the
same name cannot record a bogus spike — the first sample only re-baselines.

## ASUS page shell (do not strip it)

Stock ASUS content pages are not standalone documents: each one draws its own
left menu, footer and tab strip. Three things are easy to get wrong here, and
all three were bugs first:

1. **`show_menu()` needs the containers.** `state.js` builds the menu into
   `#mainMenu`, `#subMenu`, `#tabMenu` and writes the footer into `#footer`.
   A page without `<div id="footer"></div>` throws inside `show_menu()`, which
   aborts the inline `onload="show_menu();init();"` — no menu, and `init()`
   never runs, so the page looks empty.
2. **Chart.js must load before `state.js`.** `state.js` pulls in RequireJS;
   Chart.js is a UMD bundle and, once `define` exists, registers as an AMD
   module instead of defining `window.Chart`. The stock pages load it early for
   this reason. Symptom: `ReferenceError: Chart is not defined`.
3. **The page selector is our navigation here.** In AP mode ASUS renders no tab
   strip for this section, so the page carries its own
   Realtime / Last 24 hours / Daily / Monthly selector. It navigates to the
   three pages this feature installs plus the stock realtime page.

## Deliberate limits

* **No per-client or per-app numbers.** That needs the DPI stack (`bwdpi` +
  Trend Micro signatures), which is proprietary; the `TrafficAnalyzer_Statistic`
  tab therefore stays hidden (it is excluded by a separate `tabs` rule).
* **Bytes, not shaped traffic.** `tc -s` classes would describe the shaper, not
  what the node actually forwarded; the counters are the honest source here.
* **5-minute resolution.** Enough for 24 h/daily/monthly; realtime stays with the
  stock page and its `/update.cgi` polling.

## Verify by hand

```sh
sh /tmp/mnt/FRANKLIN/franklin/features/traffic-monitor/collect.sh
sqlite3 /tmp/mnt/FRANKLIN/traffic-monitor/traffic.db \
        "SELECT ifname, COUNT(*) FROM samples GROUP BY ifname;"
head -c 200 /www/traffic-data.asp
```

Then open `Traffic Analyzer → Traffic Monitor` in the UI (or
`/Main_TrafficMonitor_last24.asp`, `..._daily.asp`, `..._monthly.asp`).
