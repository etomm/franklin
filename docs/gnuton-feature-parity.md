# gnuton / Merlin feature parity

Franklin cannot become gnuton/Merlin firmware, but it can port **userland**
features. This document tracks parity.

Version legend (reference builds used in the table below):
- **gnuton 3006.102.9** — gnuton master, pinned in `GNUTON_REF` (commit
  `281addbccde64f85a772134b5c0de214182b6a06`).
- **Merlin 388.2** — ASUSWRT-Merlin 388.x reference line.
- **Stock 3.0.0.4.388** — stock ASUSWRT on the XT9 (`3.0.0.4.388_24854`).
- **Franklin 0.1** — this project's current target (in development).

The "Available in (upstream)" column names the reference build that provides
the feature, not the version that first introduced it. The "Ported?" column is
a quick check: ✅ = ported, 📋 = planned, 🔄 = in progress/research, ❌ = not
ported (won't port), — = handled by stock firmware (not a porting target).

## Summary table

| # | Feature | Available in (upstream) | Franklin (mine) | Ported? | Notes |
|---|---|---|---|---|---|
| 1 | Boot-time scripts (services-start, firewall-start, nat-start, wan-start) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | asusware.arm `S99franklin-boot` hook |
| 2 | Custom scripts in `/jffs/scripts` | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | `/jffs/franklin` scripts |
| 3 | IPTV / VLAN port tagging (wired) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | ethswctl softswitch map |
| 4 | JFFS partition (persistent storage) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | `/jffs` used for profiles/logs |
| 5 | VLAN / switch control (ethswctl, softswitch) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | XT9 verified sequence |
| 6 | Cake qdisc | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | needs compatible `sch_cake.ko` |
| 7 | IGMP snooping / multicast | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | firmware-level mostly |
| 8 | QoS / bandwidth limiter | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | tc + IFB |
| 9 | SQM with fq_codel / ifb | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | kernel has IFB + fq_codel |
| 10 | amtm (ASUSWRT Merlin Terminal Menu) | gnuton 3006.102.9 | 0.1 (Planned) | 📋 | Franklin's own menu equivalent |
| 11 | Bridge management (brctl) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | wrappers |
| 12 | CIFS mount (client) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware cifs-utils |
| 13 | cron / scheduled tasks | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | Entware cron or shell loop |
| 14 | DDNS (custom providers) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware ddns-scripts |
| 15 | DHCP static leases / custom config | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware dnsmasq |
| 16 | Diagnostics (tcpdump, iperf3, ethtool, mtr) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | stock has iperf3, ethtool, tc, brctl, jq, curl, wget; tcpdump via Entware |
| 17 | Disk monitoring (smartmontools) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware smartmontools |
| 18 | Disk spindown / power management | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware hdparm |
| 19 | DNS (dnsmasq, custom config) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware dnsmasq |
| 20 | DNS-over-TLS (DoT) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware (stubby/unbound) |
| 21 | DNSFilter / ad blocking | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware |
| 22 | Download manager (aria2) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware aria2 |
| 23 | Entware / opkg package ecosystem | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | `armv7sf-k3.2` repo |
| 24 | Firewall (iptables) rules | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | wrappers + Entware |
| 25 | Integrated web UI (modify existing stock pages) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | bind-mount overlay of `/www`, edit existing pages; preferred over separate :8080 |
| 26 | LED control | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | wrappers |
| 27 | Network tools (ping, traceroute, nslookup, WoL) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | stock + Entware |
| 28 | NFS (server/export) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware nfs-utils |
| 29 | NTP client/server | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | Entware ntpd |
| 30 | NVRAM save/restore | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | wrappers |
| 31 | NVRAM tools / config export | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | wrappers around nvram |
| 32 | Reboot schedule | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | cron job |
| 33 | SNMP | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via Entware snmpd |
| 34 | SSH (dropbear / openssh) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | stock SSH + Entware openssh |
| 35 | System log / syslog | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | Entware syslog-ng |
| 36 | Temperature monitoring | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | via sysfs/Entware |
| 37 | Web UI overlay over `/www` (bind mount) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | preferred approach: modify existing pages in place |
| 38 | Adaptive QoS | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware provides QoS |
| 39 | AiMesh / mesh management | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 40 | AiProtection (Trend Micro) | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 41 | AP / Bridge / Repeater / Media bridge modes | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 42 | Cloud sync (Dropbox etc.) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles |
| 43 | Firmware upgrade helpers | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 44 | FTP server | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles; Entware alternative available |
| 45 | Guest network | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 46 | IPSec VPN | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles |
| 47 | IPv6 (native, 6in4, 6to4, 6rd) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles IPv6 |
| 48 | MAC filter | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 49 | Media server (minidlna) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock provides minidlna (`/usr/sbin/minidlna`) |
| 50 | NAT acceleration (CTF/FA) | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 51 | Network map / client list | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 52 | Parental controls | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 53 | Port forwarding / virtual server / DMZ | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 54 | Samba / SMB file sharing | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles; Entware alternative available |
| 55 | Samba recycle bin | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles |
| 56 | Time Machine (AFP) backup | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles |
| 57 | Traffic Analyzer / bandwidth monitor | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 58 | USB modem (3G/4G) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles |
| 59 | USB storage (Samba, FTP, DLNA, printer) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles; Entware alternative available |
| 60 | VPN client (OpenVPN) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles; Entware alternative available |
| 61 | VPN server (OpenVPN) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles; Entware alternative available |
| 62 | Web UI HTTPS admin | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |
| 63 | WebDAV | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles |
| 64 | WireGuard | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | — | stock firmware handles; Entware alternative available |
| 65 | Wireless tuning (band steering, smart connect, WPS) | Stock 3.0.0.4.388 | n/a (Stock handles) | — | stock firmware handles |

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
- **Integrated web UI (4, 10):** Rather than a separate :8080 server, Franklin
  prefers to **modify existing stock pages in place** via a bind-mounted
  overlay of `/www`, editing the pages/menus the stock UI already serves.
  This keeps the stock look and avoids a second web server.
- **Diagnostics (5):** Network diagnostic tools (packet capture, throughput,
  interface stats).
- **VLAN / switch control (6):** Low-level Broadcom switch configuration
  (`ethswctl`), including the verified hw-switching + softswitch sequence.
- **Bridge management (7):** Linux bridge (`brctl`) configuration and inspection.
- **SQM fq_codel/ifb (8):** Traffic shaping using the kernel's built-in
  `fq_codel` and `ifb`, without extra modules.
- **Cake qdisc (9):** Advanced traffic shaper; requires a compatible
  `sch_cake.ko` module.

### Network and routing
- **Adaptive QoS (11):** ASUS's QoS engine is provided by stock firmware;
  Franklin does not reimplement it.
- **Port forwarding / virtual server / DMZ (26):** Handled by stock firmware.
- **IPv6 (27):** Native and tunneled IPv6 is handled by stock firmware.
- **DDNS (28):** Dynamic DNS updates; doable via Entware ddns-scripts.
- **Firewall (25):** iptables rule management; Franklin will wrap and extend.
- **DNS (21) / DNSFilter (22) / DoT (23):** DNS resolution, ad blocking,
  and encrypted DNS via Entware resolvers.
- **DHCP (24):** Static leases and custom dnsmasq config via Entware.
- **IPTV / VLAN tagging wired (43):** Passing VLAN 100 between wired ports
  via the ethswctl softswitch map (verified on XT9).
- **QoS / bandwidth limiter (44):** Traffic control via `tc` + IFB.
- **IGMP snooping / multicast (56):** Mostly firmware-level switch feature.
- **NAT acceleration CTF/FA (57):** Hardware NAT offload; stock firmware handles.

### VPN
- **OpenVPN server/client (17, 18), WireGuard (19), IPSec (20):** Provided by
  stock firmware; Franklin does not reimplement them, but users can run VPN via
  Entware if needed.

### Storage and USB
- **USB storage (Samba/FTP/DLNA/printer) (15), Time Machine (16), WebDAV (36),
  Samba recycle bin (60), Cloud sync (61):** Provided by stock firmware; Franklin
  can add equivalents via Entware (samba4, vsftpd, minidlna, rclone).
- **NFS (35), CIFS mount (58):** Network filesystems via Entware.
- **Download manager (37):** aria2 via Entware.
- **Media server (38):** stock provides minidlna (`/usr/sbin/minidlna`); Franklin
  can add/replace via Entware if needed.
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
- **Firmware upgrade (48), USB modem (50):** stock firmware handles.
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
