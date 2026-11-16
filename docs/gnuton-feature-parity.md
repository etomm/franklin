# gnuton / Merlin feature parity

Franklin cannot become gnuton/Merlin firmware, but it can port **userland**
features. This document tracks parity. "Upstream" refers to ASUSWRT-Merlin /
gnuton where the feature originates; "Franklin" is this project's status.

## Summary table

| # | Feature | Upstream (Merlin/gnuton) | Franklin (mine) | Notes |
|---|---|---|---|---|
| 1 | Boot-time scripts (services-start, firewall-start, nat-start, wan-start) | Merlin 386+ / gnuton | Ported | asusware.arm `S99franklin-boot` hook |
| 2 | Entware / opkg package ecosystem | Merlin 386+ / gnuton | Planned | `armv7sf-k3.2` repo |
| 3 | cron / scheduled tasks | Merlin 386+ / gnuton | Planned | Entware cron or shell loop |
| 4 | Custom web UI on alternate port | Merlin 386+ / gnuton | Planned | lighttpd + CGI on :8080 |
| 5 | Diagnostics (tcpdump, iperf3, ethtool, mtr) | Merlin 386+ / gnuton | Planned | via Entware |
| 6 | VLAN / switch control (ethswctl, softswitch) | Merlin 386+ / gnuton | Ported | XT9 verified sequence |
| 7 | Bridge management (brctl) | Merlin 386+ / gnuton | Planned | wrappers |
| 8 | SQM with fq_codel / ifb | Merlin 386+ / gnuton | Research | kernel has IFB + fq_codel |
| 9 | Cake qdisc | Merlin 386+ / gnuton | Research | needs compatible `sch_cake.ko` |
| 10 | Web UI overlay over `/www` (bind mount) | Merlin 386+ / gnuton | Planned | no httpd patch |
| 11 | Adaptive QoS | Merlin 386+ / gnuton | Not planned | firmware-level |
| 12 | AiMesh / mesh management | Stock ASUSWRT | Not applicable | stock firmware handles |
| 13 | AiProtection (Trend Micro) | Stock ASUSWRT | Not applicable | stock firmware handles |
| 14 | Traffic Analyzer / bandwidth monitor | Stock ASUSWRT | Not applicable | stock firmware handles |
| 15 | USB storage (Samba, FTP, DLNA, printer) | Merlin 386+ / gnuton | Not planned | firmware-level; use Entware |
| 16 | Time Machine (AFP) backup | Merlin 386+ / gnuton | Not planned | firmware-level |
| 17 | VPN server (OpenVPN) | Merlin 386+ / gnuton | Not planned | firmware-level; use Entware |
| 18 | VPN client (OpenVPN) | Merlin 386+ / gnuton | Not planned | firmware-level; use Entware |
| 19 | WireGuard | Merlin 386+ / gnuton | Not planned | firmware-level; use Entware |
| 20 | IPSec VPN | Merlin 386+ / gnuton | Not planned | firmware-level |
| 21 | DNS (dnsmasq, custom config) | Merlin 386+ / gnuton | Planned | via Entware dnsmasq |
| 22 | DNSFilter / ad blocking | Merlin 386+ / gnuton | Planned | via Entware |
| 23 | DNS-over-TLS (DoT) | Merlin 386+ / gnuton | Planned | via Entware (stubby/unbound) |
| 24 | DHCP static leases / custom config | Merlin 386+ / gnuton | Planned | via Entware dnsmasq |
| 25 | Firewall (iptables) rules | Merlin 386+ / gnuton | Planned | wrappers + Entware |
| 26 | Port forwarding / virtual server / DMZ | Stock ASUSWRT | Not applicable | stock firmware handles |
| 27 | IPv6 (native, 6in4, 6to4, 6rd) | Merlin 386+ / gnuton | Not planned | firmware-level |
| 28 | DDNS (custom providers) | Merlin 386+ / gnuton | Planned | via Entware ddns-scripts |
| 29 | JFFS partition (persistent storage) | Merlin 386+ / gnuton | Ported | `/jffs` used for profiles/logs |
| 30 | NVRAM tools / config export | Merlin 386+ / gnuton | Planned | wrappers around nvram |
| 31 | SSH (dropbear / openssh) | Merlin 386+ / gnuton | Planned | stock SSH + Entware openssh |
| 32 | SNMP | Merlin 386+ / gnuton | Planned | via Entware snmpd |
| 33 | Samba / SMB file sharing | Merlin 386+ / gnuton | Not planned | firmware-level; use Entware |
| 34 | FTP server | Merlin 386+ / gnuton | Not planned | firmware-level; use Entware |
| 35 | NFS (server/export) | Merlin 386+ / gnuton | Planned | via Entware nfs-utils |
| 36 | WebDAV | Merlin 386+ / gnuton | Not planned | firmware-level |
| 37 | Download manager (aria2) | Merlin 386+ / gnuton | Planned | via Entware aria2 |
| 38 | Media server (minidlna) | Merlin 386+ / gnuton | Planned | via Entware minidlna |
| 39 | Disk monitoring (smartmontools) | Merlin 386+ / gnuton | Planned | via Entware smartmontools |
| 40 | Temperature monitoring | Merlin 386+ / gnuton | Planned | via sysfs/Entware |
| 41 | LED control | Merlin 386+ / gnuton | Planned | wrappers |
| 42 | Guest network | Stock ASUSWRT | Not applicable | stock firmware handles |
| 43 | IPTV / VLAN port tagging (wired) | Merlin 386+ / gnuton | Ported | ethswctl softswitch map |
| 44 | QoS / bandwidth limiter | Merlin 386+ / gnuton | Research | tc + IFB |
| 45 | Network tools (ping, traceroute, nslookup, WoL) | Merlin 386+ / gnuton | Planned | stock + Entware |
| 46 | System log / syslog | Merlin 386+ / gnuton | Planned | Entware syslog-ng |
| 47 | NTP client/server | Merlin 386+ / gnuton | Planned | Entware ntpd |
| 48 | Firmware upgrade helpers | Merlin 386+ / gnuton | Not planned | stock firmware handles |
| 49 | Reboot schedule | Merlin 386+ / gnuton | Planned | cron job |
| 50 | USB modem (3G/4G) | Merlin 386+ / gnuton | Not planned | firmware-level |
| 51 | Network map / client list | Stock ASUSWRT | Not applicable | stock firmware handles |
| 52 | Parental controls | Stock ASUSWRT | Not applicable | stock firmware handles |
| 53 | MAC filter | Stock ASUSWRT | Not applicable | stock firmware handles |
| 54 | Wireless tuning (band steering, smart connect, WPS) | Stock ASUSWRT | Not applicable | stock firmware handles |
| 55 | AP / Bridge / Repeater / Media bridge modes | Stock ASUSWRT | Not applicable | stock firmware handles |
| 56 | IGMP snooping / multicast | Merlin 386+ / gnuton | Research | firmware-level mostly |
| 57 | NAT acceleration (CTF/FA) | Stock ASUSWRT | Not applicable | firmware-level |
| 58 | CIFS mount (client) | Merlin 386+ / gnuton | Planned | via Entware cifs-utils |
| 59 | Disk spindown / power management | Merlin 386+ / gnuton | Planned | via Entware hdparm |
| 60 | Samba recycle bin | Merlin 386+ / gnuton | Not planned | firmware-level |
| 61 | Cloud sync (Dropbox etc.) | Merlin 386+ / gnuton | Not planned | firmware-level |
| 62 | amtm (ASUSWRT Merlin Terminal Menu) | gnuton / Merlin | Planned | Franklin's own menu equivalent |
| 63 | Custom scripts in `/jffs/scripts` | Merlin 386+ / gnuton | Ported | `/jffs/franklin` scripts |
| 64 | NVRAM save/restore | Merlin 386+ / gnuton | Planned | wrappers |
| 65 | Web UI HTTPS admin | Stock ASUSWRT | Not applicable | stock firmware handles |

## Feature descriptions

### Boot and persistence
- **Boot-time scripts (1):** Scripts that run automatically at boot (e.g.
  `services-start`, `firewall-start`). Franklin implements this via the
  verified `asusware.arm` app-folder hook, since NVRAM `script_*` hooks do
  not run at boot on this firmware.
- **Entware / opkg (2):** Package manager providing thousands of prebuilt
  binaries. Foundation for most Franklin "planned" features.
- **cron / scheduled tasks (3):** Periodic job scheduler. Used for reboots,
  maintenance, and watchdogs.
- **Custom web UI (4):** A separate control panel on another port (e.g. :8080)
  instead of patching the stock `httpd`.
- **Diagnostics (5):** Network diagnostic tools (packet capture, throughput,
  interface stats).
- **VLAN / switch control (6):** Low-level Broadcom switch configuration
  (`ethswctl`), including the verified hw-switching + softswitch sequence.
- **Bridge management (7):** Linux bridge (`brctl`) configuration and inspection.
- **SQM fq_codel/ifb (8):** Traffic shaping using the kernel's built-in
  `fq_codel` and `ifb`, without extra modules.
- **Cake qdisc (9):** Advanced traffic shaper; requires a compatible
  `sch_cake.ko` module.
- **Web UI overlay (10):** Bind-mounting a modified `/www` over the stock one
  without patching `httpd`.

### Network and routing
- **Adaptive QoS (11):** ASUS's built-in QoS engine. Firmware-level; out of
  scope for a userland layer.
- **Port forwarding / virtual server / DMZ (26):** Handled by stock firmware.
- **IPv6 (27):** Tunneling and native IPv6. Firmware-level.
- **DDNS (28):** Dynamic DNS updates; doable via Entware ddns-scripts.
- **Firewall (25):** iptables rule management; Franklin will wrap and extend.
- **DNS (21) / DNSFilter (22) / DoT (23):** DNS resolution, ad blocking,
  and encrypted DNS via Entware resolvers.
- **DHCP (24):** Static leases and custom dnsmasq config via Entware.
- **IPTV / VLAN tagging wired (43):** Passing VLAN 100 between wired ports
  via the ethswctl softswitch map (verified on XT9).
- **QoS / bandwidth limiter (44):** Traffic control via `tc` + IFB.
- **IGMP snooping / multicast (56):** Mostly firmware-level switch feature.
- **NAT acceleration CTF/FA (57):** Hardware NAT offload; firmware-level.

### VPN
- **OpenVPN server/client (17, 18), WireGuard (19), IPSec (20):** Firmware-level
  VPN stacks. Franklin does not reimplement them; users can run VPN via Entware
  if needed.

### Storage and USB
- **USB storage (Samba/FTP/DLNA/printer) (15), Time Machine (16), WebDAV (36),
  Samba recycle bin (60), Cloud sync (61):** Firmware-level USB apps. Franklin
  can add equivalents via Entware (samba4, vsftpd, minidlna, rclone).
- **NFS (35), CIFS mount (58):** Network filesystems via Entware.
- **Download manager (37):** aria2 via Entware.
- **Media server (38):** minidlna via Entware.
- **Disk monitoring (39), spindown (59), temperature (40):** via Entware
  (smartmontools, hdparm) and sysfs.
- **LED control (41):** Wrappers around LED control interfaces.

### System and admin
- **JFFS (29):** Persistent storage partition; Franklin uses `/jffs` for
  profiles and logs.
- **NVRAM tools (30, 64):** Save/restore and wrapper utilities.
- **SSH (31):** Stock SSH plus optional Entware openssh.
- **SNMP (32):** via Entware snmpd.
- **System log (46), NTP (47), reboot schedule (49):** via Entware.
- **Firmware upgrade (48), USB modem (50):** firmware-level; out of scope.
- **amtm (62):** Terminal menu; Franklin provides its own equivalent.
- **Custom scripts (63):** `/jffs/franklin` script directory.
- **Web UI HTTPS admin (65):** stock firmware handles.

### Wireless, mesh, and access control
- **AiMesh (12), AiProtection (13), Traffic Analyzer (14), Guest network (42),
  Network map (51), Parental controls (52), MAC filter (53), Wireless tuning (54),
  AP/Bridge/Repeater/Media bridge (55), NAT acceleration (57):** Stock firmware
  features; Franklin does not replace them.

## How to port a feature
1. Check `GNUTON_REF` pinned commit; fetch upstream with `tools/fetch-gnuton.sh`
   (run in WSL).
2. Locate the relevant file(s) in `vendor/gnuton`.
3. Copy + adapt into Franklin, recording the source path + commit in a header
   comment.
4. Update the table and description above; change status accordingly.
5. Test on device; keep the recovery path in `docs/recovery.md`.
