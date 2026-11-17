# gnuton / Merlin feature parity

Franklin cannot become gnuton/Merlin firmware, but it can port **userland**
features. This document tracks parity. A sortable (click-to-sort) version of
the table is available in [`gnuton-feature-parity.html`](gnuton-feature-parity.html).
Detailed per-feature plans (what it does, modes, requirements, tested status)
are in [`features/README.md`](features/README.md); each row below links to its plan.

Version legend (reference builds used in the table below):
- **gnuton 3006.102.9** — gnuton master, pinned in `GNUTON_REF` (commit
  `281addbccde64f85a772134b5c0de214182b6a06`).
- **Merlin 388.2** — ASUSWRT-Merlin 388.x reference line.
- **Stock 3.0.0.4.388** — stock ASUSWRT on the XT9 (`3.0.0.4.388_24854`).
- **Franklin 0.1** — this project's current target (in development).

The "Available in (upstream)" column names the reference build that provides
the feature, not the version that first introduced it. The table is split into
two status columns: **Backend** (server-side implementation) and **UI**
(user-facing interface). A feature is only fully ported when both are done.
Legend: ✅ = done, 🔄 = in progress/research, 📋 = planned, ❌ = not ported
(won't port), 🏠 = handled by stock firmware (not a porting target), 🚫 = no UI
needed, ⛔ = gnuton has firmware-level fixes/optimizations that are not
transferable to Franklin, · = no unportable gnuton fixes identified. A feature
is only fully ported when both Backend and UI are ✅.

## Summary table

| # | Feature | Available in (upstream) | Franklin (mine) | Backend | UI | Notes |
|---|---|---|---|---|---|---|
| 1 | IPTV / VLAN port tagging (wired) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | 📋 | ethswctl softswitch map [plan](features/boot-hook.md) |
| 2 | VLAN / switch control (ethswctl, softswitch) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | 📋 | XT9 verified sequence [plan](features/boot-hook.md) |
| 3 | Boot-time scripts (services-start, firewall-start, nat-start, wan-start) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | 🚫 | asusware.arm `S99franklin-boot` hook [plan](features/boot-hook.md) |
| 4 | Custom scripts in `/jffs/scripts` | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | 🚫 | `/jffs/franklin` scripts [plan](features/custom-scripts.md) |
| 5 | JFFS partition (persistent storage) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Ported) | ✅ | 🚫 | `/jffs` used for profiles/logs [plan](features/jffs.md) |
| 6 | Cake qdisc | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | 📋 | needs compatible `sch_cake.ko` [plan](features/cake-qos.md) |
| 7 | IGMP snooping / multicast | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | 📋 | firmware-level mostly |
| 8 | QoS / bandwidth limiter | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | 📋 | tc + IFB [plan](features/cake-qos.md) |
| 9 | SQM with fq_codel / ifb | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Research) | 🔄 | 📋 | kernel has IFB + fq_codel [plan](features/cake-qos.md) |
| 10 | amtm (ASUSWRT Merlin Terminal Menu) | gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | Franklin's own menu equivalent [plan](features/amtm.md) |
| 11 | CIFS mount (client) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware cifs-utils |
| 12 | DDNS (custom providers) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware ddns-scripts [plan](features/ddns.md) |
| 13 | DHCP static leases / custom config | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware dnsmasq |
| 14 | Diagnostics (tcpdump, iperf3, ethtool, mtr) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | stock has iperf3, ethtool, tc, brctl, jq, curl, wget; tcpdump via Entware [plan](features/network-tools.md) |
| 15 | Disk monitoring (smartmontools) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware smartmontools [plan](features/disk-monitoring.md) |
| 16 | Disk spindown / power management | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware hdparm |
| 17 | DNS (dnsmasq, custom config) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware dnsmasq [plan](features/dnsmasq-custom.md) |
| 18 | DNS-over-TLS (DoT) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware (stubby/unbound) [plan](features/dns-over-tls.md) |
| 19 | DNSFilter / ad blocking | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware [plan](features/dns-director.md) |
| 20 | Download manager (aria2) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware aria2 [plan](features/entware.md) |
| 21 | Firewall (iptables) rules | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | wrappers + Entware [plan](features/firewall-custom.md) |
| 22 | Integrated web UI (modify existing stock pages) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | bind-mount overlay of `/www`, edit existing pages; preferred over separate :8080 [plan](features/web-ui.md) |
| 23 | LED control | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | wrappers [plan](features/led-control.md) |
| 24 | Network tools (ping, traceroute, nslookup, WoL) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | stock + Entware [plan](features/network-tools.md) |
| 25 | NFS (server/export) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware nfs-utils [plan](features/nfs.md) |
| 26 | NTP client/server | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | Entware ntpd [plan](features/ntp.md) |
| 27 | NVRAM save/restore | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | wrappers [plan](features/nvram-tools.md) |
| 28 | NVRAM tools / config export | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | wrappers around nvram [plan](features/nvram-tools.md) |
| 29 | Reboot schedule | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | cron job [plan](features/reboot-schedule.md) |
| 30 | SNMP | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via Entware snmpd [plan](features/snmp.md) |
| 31 | SSH (dropbear / openssh) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | stock SSH + Entware openssh |
| 32 | System log / syslog | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | Entware syslog-ng |
| 33 | Temperature monitoring | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | via sysfs/Entware [plan](features/temperature-monitoring.md) |
| 34 | Web UI overlay over `/www` (bind mount) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 📋 | preferred approach: modify existing pages in place [plan](features/web-ui.md) |
| 35 | Bridge management (brctl) | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 🚫 | wrappers [plan](features/boot-hook.md) |
| 36 | cron / scheduled tasks | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 🚫 | Entware cron or shell loop [plan](features/cron.md) |
| 37 | Entware / opkg package ecosystem | Merlin 388.2 / gnuton 3006.102.9 | 0.1 (Planned) | 📋 | 🚫 | `armv7sf-k3.2` repo [plan](features/entware.md) |
| 38 | Adaptive QoS | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#adaptive-qos--qos-engine) | 🏠 | stock firmware provides QoS [plan](features/adaptive-qos.md) |
| 39 | AiMesh / mesh management | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 [⛔](#aimesh--mesh-stability) | 🏠 | stock firmware handles [plan](features/aimesh.md) |
| 40 | AiProtection (Trend Micro) | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 41 | AP / Bridge / Repeater / Media bridge modes | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 42 | Cloud sync (Dropbox etc.) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 43 | Firmware upgrade helpers | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 44 | FTP server | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#usb-apps-samba-ftp-webdav-dlna-time-machine) | 🏠 | stock firmware handles; Entware alternative available [plan](features/samba-ftp-webdav.md) |
| 45 | Guest network | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles [plan](features/guest-network.md) |
| 46 | IPSec VPN | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#vpn-stack-openvpn-wireguard-ipsec) | 🏠 | stock firmware handles [plan](features/ipsec-vpn.md) |
| 47 | IPv6 (native, 6in4, 6to4, 6rd) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#kernel-and-network-stack) | 🏠 | stock firmware handles IPv6 |
| 48 | MAC filter | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 49 | Media server (minidlna) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 | 🏠 | stock provides minidlna (`/usr/sbin/minidlna`) [plan](features/samba-ftp-webdav.md) |
| 50 | NAT acceleration (CTF/FA) | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 [⛔](#nat-acceleration-ctffa) | 🏠 | stock firmware handles [plan](features/nat-acceleration.md) |
| 51 | Network map / client list | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles [plan](features/networkmap.md) |
| 52 | Parental controls | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 53 | Port forwarding / virtual server / DMZ | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 54 | Samba / SMB file sharing | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#usb-apps-samba-ftp-webdav-dlna-time-machine) | 🏠 | stock firmware handles; Entware alternative available [plan](features/samba-ftp-webdav.md) |
| 55 | Samba recycle bin | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles [plan](features/samba-ftp-webdav.md) |
| 56 | Time Machine (AFP) backup | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles [plan](features/samba-ftp-webdav.md) |
| 57 | Traffic Analyzer / bandwidth monitor | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 58 | USB modem (3G/4G) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles |
| 59 | USB storage (Samba, FTP, DLNA, printer) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#usb-apps-samba-ftp-webdav-dlna-time-machine) | 🏠 | stock firmware handles; Entware alternative available [plan](features/samba-ftp-webdav.md) |
| 60 | VPN client (OpenVPN) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#vpn-stack-openvpn-wireguard-ipsec) | 🏠 | stock firmware handles; Entware alternative available [plan](features/openvpn-client.md) |
| 61 | VPN server (OpenVPN) | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#vpn-stack-openvpn-wireguard-ipsec) | 🏠 | stock firmware handles; Entware alternative available [plan](features/openvpn-server.md) |
| 62 | Web UI HTTPS admin | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 | 🏠 | stock firmware handles [plan](features/web-ui.md) |
| 63 | WebDAV | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#usb-apps-samba-ftp-webdav-dlna-time-machine) | 🏠 | stock firmware handles [plan](features/samba-ftp-webdav.md) |
| 64 | WireGuard | Merlin 388.2 / gnuton 3006.102.9 | n/a (Stock handles) | 🏠 [⛔](#vpn-stack-openvpn-wireguard-ipsec) | 🏠 | stock firmware handles; Entware alternative available [plan](features/wireguard-client.md) |
| 65 | Wireless tuning (band steering, smart connect, WPS) | Stock 3.0.0.4.388 | n/a (Stock handles) | 🏠 [⛔](#wireless-tuning) | 🏠 | stock firmware handles |

## Feature descriptions

### Boot and persistence
- **Boot-time scripts (1):** ... (half-ported: boot hook works, UI pending).
- **Custom scripts (63):** ... (half-ported: scripts work, UI pending).
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

## gnuton-specific fixes and optimizations (not transferable)

gnuton (and ASUSWRT-Merlin) carry firmware-level fixes and optimizations that
Franklin cannot replicate, because Franklin is a userland layer and does not
patch the kernel, drivers, `httpd`, `rc`, or ASUSWRT's compiled backend.
These are marked ⛔ in the "Unportable (gnuton fixes)" column. Each item
links to the relevant gnuton commits (search):

<a id="httpd-optimizations"></a>
- **httpd optimizations** — gnuton rebuilt `httpd` (larger binary, different
  hash). Tested on stock XT9: it runs on a separate port with `libovpn.so` and
  `cwd=/www`, and serves the stock UI. So this is **partially portable**
  (daemon swap is possible), though it is still not something Franklin does by
  default; the preferred path remains the `/www` overlay.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=httpd+optimization&type=commits)
<a id="adaptive-qos--qos-engine"></a>
- **Adaptive QoS / QoS engine** — gnuton's QoS improvements live in the
  firmware's QoS daemon and kernel qdisc integration.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=adaptive+qos&type=commits)
<a id="vpn-stack-openvpn-wireguard-ipsec"></a>
- **VPN stack (OpenVPN, WireGuard, IPSec)** — gnuton ships VPN fixes in
  the firmware's VPN daemons and kernel modules.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=vpn+killswitch&type=commits)
<a id="aimesh--mesh-stability"></a>
- **AiMesh / mesh stability** — mesh coordination is handled by the firmware
  and radio drivers.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=aimesh&type=commits)
<a id="usb-apps-samba-ftp-webdav-dlna-time-machine"></a>
- **USB apps (Samba, FTP, WebDAV, DLNA, Time Machine)** — gnuton updates
  these compiled daemons and their firmware integration.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=webdav&type=commits)
<a id="nat-acceleration-ctffa"></a>
- **NAT acceleration (CTF/FA)** — hardware NAT offload is firmware/driver level.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=nat+acceleration&type=commits)
<a id="wireless-tuning"></a>
- **Wireless tuning** — band steering, smart connect, and WPS live in the
  radio firmware/drivers.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=wireless+tuning&type=commits)
<a id="kernel-and-network-stack"></a>
- **Kernel and network stack** — gnuton's kernel fixes, module updates, and
  netfilter optimizations are not portable to a stock kernel.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=kernel+fix&type=commits)
<a id="memory-and-boot-optimizations"></a>
- **Memory and boot optimizations** — gnuton tunes startup and memory usage
  in `rc`/init.
  [search commits](https://github.com/gnuton/asuswrt-merlin.ng/search?q=boot+optimization&type=commits)

Full gnuton changelog (all releases):
[Changelog-NG.txt](https://github.com/gnuton/asuswrt-merlin.ng/blob/master/Changelog-NG.txt)

Franklin's approach is to provide equivalent functionality via Entware and
userland scripts where possible, and to document the gap honestly.

## How to port a feature
1. Check `GNUTON_REF` pinned commit; fetch upstream with `tools/fetch-gnuton.sh`
   (run in WSL).
2. Locate the relevant file(s) in `vendor/gnuton`.
3. Copy + adapt into Franklin, recording the source path + commit in a header
   comment.
4. Update the table and description above; change status accordingly.
5. Test on device; keep the recovery path in `docs/recovery.md`.
