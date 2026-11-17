# Firmware comparison: XT8 (3.0.0.4.388_24814) vs XT9 (3.0.0.4.388_24854)

The XT8 firmware was downloaded and extracted into `firmware/xt8/` (gitignored)
for comparison with the XT9 stock firmware running on the test device.

## Source
- XT8: ASUS ZenWiFi AX (XT8) HW v1.0, firmware 3.0.0.4.388_24814 (2026/05/15)
  (`FW_ZENWIFI_XT8_300438824814.zip`), extracted from the UBI/squashfs image.
- XT9: live device at 192.168.0.4, firmware 3.0.0.4.388_24854-g9c246e8.

## Findings
- `/www` is essentially identical: only `Advanced_Smart_Home_IFTTT.asp` is
  present in XT8 but absent from XT9. All Franklin-relevant pages (AdaptiveQoS,
  AiMesh, AiProtection, VPN, AiDisk, TimeMachine, ParentalControl, IPTV, IPv6,
  SwitchCtrl, TrafficAnalyzer, etc.) exist on both.
- `/usr/sbin` differs only slightly:
  - XT8 has `dbus-daemon`, `epi_ttcp` (not on XT9).
  - XT9 has `brcm_cled.sh`, `chroot`, `ethtool`, `mkfs.ubifs`, `mtdinfo`,
    `nanddump`, `ubinfo` (not on XT8).
- Both share the same kernel (4.19.183), Broadcom userland, lighttpd,
  minidlna, openvpn, wg, dnsmasq, smbd/nmbd, iperf3, jq, curl, wget, bash,
  tc, brctl.
- Missing on both (Entware required): tcpdump, smartctl, hdparm, aria2c,
  snmpd, ntpd, syslog-ng, rclone, nfsd/exportfs, cifs.mount, python, perl.

# Firmware comparison: XT8 (3.0.0.4.388_24814) vs XT9 (3.0.0.4.388_24854)

The XT8 firmware was downloaded and extracted into `firmware/xt8/` (gitignored)
for comparison with the XT9 stock firmware running on the test device.

## Source
- XT8: ASUS ZenWiFi AX (XT8) HW v1.0, firmware 3.0.0.4.388_24814 (2026/05/15)
  (`FW_ZENWIFI_XT8_300438824814.zip`), extracted from the UBI/squashfs image.
- XT9: live device at 192.168.0.4, firmware 3.0.0.4.388_24854-g9c246e8.

## Findings
- `/www` is essentially identical: only `Advanced_Smart_Home_IFTTT.asp` is
  present in XT8 but absent from XT9. All Franklin-relevant pages (AdaptiveQoS,
  AiMesh, AiProtection, VPN, AiDisk, TimeMachine, ParentalControl, IPTV, IPv6,
  SwitchCtrl, TrafficAnalyzer, etc.) exist on both.
- `/usr/sbin` differs only slightly:
  - XT8 has `dbus-daemon`, `epi_ttcp` (not on XT9).
  - XT9 has `brcm_cled.sh`, `chroot`, `ethtool`, `mkfs.ubifs`, `mtdinfo`,
    `nanddump`, `ubinfo` (not on XT9).
- Both share the same kernel (4.19.183), Broadcom userland, lighttpd,
  minidlna, openvpn, wg, dnsmasq, smbd/nmbd, iperf3, jq, curl, wget, bash,
  tc, brctl.
- Missing on both (Entware required): tcpdump, smartctl, hdparm, aria2c,
  snmpd, ntpd, syslog-ng, rclone, nfsd/exportfs, cifs.mount, python, perl.

## Conclusion
The XT8 and XT9 firmware are close enough that a single Franklin userland
layer applies to both. Franklin's stock-handled classifications in
`gnuton-feature-parity.md` are confirmed against real firmware. The extracted
XT8 rootfs under `firmware/xt8/rootfs/` can be grepped/diffed locally to
verify any specific file.

## gnuton firmware (extracted successfully)
- gnuton 3004.388.11_1-gnuton1 for RT-AX95Q/XT8 was downloaded into
  `firmware/gnuton-xt8/RT-AX95Q_3004_388.11_1-gnuton1_puresqubi.w` (gitignored).
  MD5 verified against the release's `.md5` file
  (`03a7940f5486dd8c5ca310356956b0c5`).
- Extraction method: `ubireader_extract_images` to strip the UBI layer (stitching
  logical blocks in order), then `unsquashfs` on the resulting
  `vol-rootfs_ubifs.ubifs` file (which starts with the `hsqs` squashfs magic).
  The rootfs is extracted into `firmware/gnuton-xt8/rootfs/`.
- Comparison with stock XT8 (3.0.0.4.388_24814):
  - `/www`: gnuton has 349 files vs 310 stock. gnuton adds Merlin features:
    `VPNDirector.asp`, `DNSDirector.asp`, `Advanced_SNMP_Content.asp`,
    `Advanced_TOR_Content.asp`, `Advanced_OpenVPNClient_Content.asp`,
    `Tools_Sysinfo.asp`, `WiFi_Insight.asp`, `QoS_Stats.asp`,
    `Main_TrafficMonitor_monthly.asp`, `Main_TrafficMonitor_settings.asp`,
    `ajax_conntrack.asp`, `ajax_sysinfo.asp`, `ajax_wificlients.asp`,
    `ajax_gettcdata.asp`, `ajax_vpn_status.asp`, and `user1.asp`..`user20.asp`.
    Stock has `Advanced_Feedback.asp`, `Captive_Portal_*_template.js.new`,
    `client.ovpn`, `Main_Security_Change_Notification.asp` (removed by gnuton).
  - `/usr/sbin`: gnuton adds `amtm`, `chroot`, `ethtool`, `exportfs`,
    `gettunnelip.sh`, `haveged`, `helper.sh`, `ipset`, `lanauth`, `mountd`,
    `nfsd`, `ntp`, `ntpd`, `portmap`, `sendmail`, `showmount`, `snmpd`,
    `statd`, `Tor`, `tune2fs`. Stock has `ahs`, `colog`, `dblog`, `dblogcmd`,
    `dhd`, `epi_ttcp`, `jitterentropy-rngd`, `lighttpd`, `lighttpd-arpping`,
    `lighttpd-monitor`, `ntpclient`, `telnetd`, `tftpd`, `uamsrv`,
    `webs_upgrade.sh`, `wl_server_socket`.
  - Both share the same kernel (4.19.183), lighttpd, minidlna, openvpn, wg,
    dnsmasq, smbd/nmbd, iperf3, jq, curl, wget, bash, tc, brctl.
- Conclusion: gnuton adds Merlin userland features (VPN Director, SNMP, Tor,
  NFS, QoS stats, WiFi insight, amtm, etc.) on top of the same stock base.
  Franklin's stock-handled classifications remain valid; gnuton's additions
  are the reference for Franklin's planned features.

## httpd portability test (gnuton httpd on stock XT9)

Tested whether gnuton's rebuilt `httpd` can run on the stock XT9 firmware:

1. Copied gnuton's `/usr/sbin/httpd` and `/usr/lib/libovpn.so` to `/tmp` on the
   router (via SSH).
2. Ran it on port 8088 with `LD_LIBRARY_PATH=/tmp /tmp/httpd-gnuton -p 8088`
   from `cwd=/www` (matching how the stock httpd is started).
3. Result: **it runs and serves the stock web UI successfully** (root, index,
   Main_Login all return 200). The stock httpd was unaffected on port 80.

Findings:
- The only missing dependency was `libovpn.so` (present in gnuton's
  `/usr/lib`, absent from stock). Supplying it via `LD_LIBRARY_PATH` is enough.
- The process must run with `cwd=/www` (the stock httpd's cwd), because httpd
  resolves pages relative to its working directory.
- It can run on a separate port (8088) without touching the stock httpd.
- Serving stock `/www` means gnuton's UI additions (VPN Director, etc.) do not
  appear — those require gnuton's `/www` files too.

Implication: gnuton's httpd is **portable** to stock firmware (contrary to the
earlier assumption), but getting gnuton's full UI still requires its `/www`
tree. Franklin can either:
- keep the stock httpd and overlay `/www` (preferred, no daemon swap), or
- run gnuton's httpd on a separate port with `libovpn.so` and gnuton's `/www`
  for a gnuton-like UI, with recovery via SSH if needed.

### Running gnuton's full UI alongside stock (tested)
Deployed on the XT9 at `http://192.168.0.4:8088` (stock UI stays on port 80):
- `/tmp/mnt/FRANKEN/gnuton-httpd` — gnuton httpd
- `/tmp/mnt/FRANKEN/gnuton-www/www/` — gnuton `/www` tree
- `/tmp/mnt/FRANKEN/gnuton-www/libovpn.so`
- `/tmp/mnt/FRANKEN/gnuton-www/libshared.so` (exports `replace_char`; without it
  some pages such as Tools_Sysinfo crash httpd with
  `undefined symbol: replace_char`)
- Started with `cd .../www && LD_LIBRARY_PATH=.../gnuton-www gnuton-httpd -p 8088`.
- gnuton-specific pages return 200: `Advanced_VPNDirector.asp`,
  `Tools_Sysinfo.asp`, `Tools_OtherSettings.asp`, `WiFi_Insight.asp`,
  `DNSDirector.asp`, etc.
- Helper: `tools/start-gnuton-webui.sh [port]`.

Note: other gnuton pages may call additional gnuton-only library symbols or
backend services that stock lacks; if httpd dies with `undefined symbol`, copy
the exporting gnuton library (find it with `strings lib/*.so usr/lib/*.so`)
into the LD_LIBRARY_PATH directory and restart.

This confirms most of gnuton's userland software can be run on stock
firmware by supplying its binaries + libraries + `/www`, without flashing.

### What ports cleanly vs what needs workarounds

Tested by running gnuton binaries on stock XT9:

- **Works directly (binaries + libs + www):**
  - `httpd` (needs `libovpn.so`, `libshared.so`, `cwd=/www`)
  - Most web pages: VPN Director, DNS Director, Tools/Sysinfo, Tools/Other,
    WiFi Insight, Traffic Monitor, etc.
- **Runs but lacks its data pipeline:**
  - `cfg_server` starts on stock (all deps present) but does not populate the
    client cache (`/tmp/nmp_cache.js`) in the format gnuton's httpd expects.
  - Consequence: gnuton's Network Map / client list shows 0 or spins.
- **Does not run:**
  - `networkmap` — fails with `client info shmget failed`: it depends on shared
    memory segments created by gnuton's `rc`/init, which stock does not set up.

Porting strategy: run gnuton's rebuilt **binaries + libs + /www** where they
work, and use **stock daemons/UI** as the workaround for daemon-coupled
features (Network Map, client list). Network map is therefore marked
stock-handled in the parity table.

### Network Map / client list: shm size mismatch (the real fix)

The empty client list was **not** a gnuton-`networkmap` problem per se — it was a
**shared-memory size mismatch**:

- Stock `networkmap` creates shm key `0x3e9` at **197,916 bytes**.
- gnuton's `httpd` and `networkmap` expect **198,168 bytes**.
- `shmget`/attach fails when the existing segment is smaller than requested, so
  gnuton's httpd gets no client table → `nmp_cache.js` stays
  `{"maclist":[],...}` → UI shows 0 clients.

Revertable fix (all from `/tmp`, USB-based):
1. `kill $(pidof networkmap)`
2. `ipcrm -M 0x3e9`
3. `LD_LIBRARY_PATH=/tmp /tmp/gnuton-bin-networkmap &`

gnuton's `networkmap` recreates `0x3e9` at 198,168 bytes; after that the stock
`networkmap` (restarted by the ASUS watchdog) attaches to the **same larger
segment** (`nattch: 2`) and keeps it populated. gnuton's httpd then reads that
shm and writes `/tmp/nmp_cache.js` on demand (on a client-list request), which
is why the cache only refreshes when a client page is loaded.

So the current state is a **dual-daemon** setup:
- gnuton `networkmap` → owns the correctly-sized shm
- stock `networkmap` → piggybacks on it (watchdog-restarted)
- gnuton `httpd` → reads the shm, writes `nmp_cache.js`

Long-term plan: **bind-mount gnuton's daemon** (and/or the shm setup) so the
correct-sized segment exists from boot, instead of relying on a manual
`ipcrm` + restart.

### gnuton-only pages (vs stock XT8) to test

URLs on the gnuton UI (`http://192.168.0.4:8088/...`), from the `/www` diff:
- `Advanced_VPNDirector.asp` — VPN Director
- `Advanced_OpenVPNClient_Content.asp` — OpenVPN client
- `Advanced_VPNStatus.asp` — VPN status
- `Advanced_TOR_Content.asp` — Tor
- `Advanced_SNMP_Content.asp` — SNMP
- `Advanced_AiDisk_NFS.asp` — AiDisk NFS
- `Advanced_Wireless_Survey.asp` — wireless survey
- `DNSDirector.asp` — DNS Director
- `GearUpAccelerator.asp` — GearUp accelerator
- `WiFi_Insight.asp` — WiFi Insight
- `QoS_Stats.asp` — QoS stats
- `Tools_Sysinfo.asp` — Tools / Sysinfo
- `Tools_OtherSettings.asp` — Tools / Other settings
- `Main_TrafficMonitor_monthly.asp` — monthly traffic monitor
- `Main_TrafficMonitor_settings.asp` — traffic monitor settings
- `UploadingJFFS.asp` — JFFS upload
- `user1.asp` … `user20.asp` — custom user pages

Notes: `cloud_*`/AiCloud pages are intentionally unsupported (removed upstream).
Some pages may show empty data or error if they need a gnuton backend service.