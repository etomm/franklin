#!/usr/bin/env python3
"""Generate Franklin feature plan files from a catalog.

Each feature becomes docs/features/<id>.md, and docs/features/README.md is the
linked index. Re-run after editing FEATURES to keep everything in sync.

Usage:  python tools/feature-catalog.py
"""
import os

OUT = os.path.join(os.path.dirname(__file__), "..", "docs", "features")

# status: tested | modular | planned | stock | research | out-of-scope
FEATURES = [
    dict(id="web-ui", title="Web UI (gnuton httpd + /www)", cat="UI",
         modes="all (AP / Router / Mesh)",
         status="tested",
         what="The gnuton/Merlin web interface: all configuration pages, menus, "
              "Traffic Monitor, Sysinfo, VPN pages, etc., served by gnuton's rebuilt httpd.",
         gnuton="A rebuilt `httpd` (larger than stock, different hash) plus the full `/www` "
                "tree and its shared libraries (`libovpn`, `libshared`, `libdisk`, `libwebapi`, ...).",
         deps="gnuton `httpd`, gnuton `/www`, all differing gnuton libs (308 files), `libovpn.so`, "
              "`libshared.so`, `libdisk.so`; `cwd=/www`; consistent `acc_num`/`acc_list`.",
         franklin="Bind-mount or run gnuton's httpd from USB on a separate port (:8088) serving "
                  "gnuton's `/www`, with all gnuton libs in `LD_LIBRARY_PATH`. Long-term: bind-mount "
                  "httpd over stock and replace `/www` (95% gnuton look/feel).",
         tested="Ran gnuton httpd + www on stock XT9 on :8088; stock UI on :80 untouched; "
                "most pages 200. Fixed `acc_num=0` segfault on Advanced_System_Content.",
         risks="httpd/lib ABI coupling to the ASUS kernel build; pages that call gnuton daemons may "
               "crash or show empty data; AiCloud pages intentionally unsupported.",
         links=["www/Advanced_System_Content.asp", "usr/sbin/httpd", "usr/lib/libwebapi.so"]),

    dict(id="vpn-director", title="VPN Director", cat="VPN",
         modes="Router (needs WAN + routing)",
         status="planned",
         what="Central policy-routing UI for OpenVPN/WireGuard clients: per-source/destination "
              "rules decide which traffic goes through which VPN tunnel (replaces ad-hoc client routing).",
         gnuton="Merlin `rc` + ip rules/routing tables; rules stored in JFFS; `httpd` page "
                "`Advanced_VPNDirector.asp`; helper `gettunnelip.sh`.",
         deps="OpenVPN/WireGuard clients; iproute2 `ip rule`/`ip route`; JFFS; gnuton rc logic.",
         franklin="Reimplement rules with `ip rule`/`ip route` in Franklin scripts, or run gnuton's "
                  "helper; no rc swap required. UI via gnuton www (bind-mounted httpd).",
         tested="Not yet (Router-mode feature; device is AP).",
         risks="Requires WAN/Router mode; complex policy routing; interaction with killswitch.",
         links=["www/Advanced_VPNDirector.asp", "usr/sbin/gettunnelip.sh"]),

    dict(id="vpn-killswitch", title="VPN Killswitch", cat="VPN",
         modes="Router (WAN + VPN client)",
         status="planned",
         what="Blocks all traffic that would bypass the VPN tunnel (prohibit rule on the main routing "
              "table), applied before WAN comes up to prevent leaks.",
         gnuton="Rewritten in Merlin `rc`: always-present `prohibit` rule; per-client; WireGuard support; "
                "rules created before WAN up.",
         deps="iptables/ip rules; VPN client enabled; nvram `vpn_client*` flags.",
         franklin="Reimplement the ip/iptables rules in a boot hook; no rc swap. Can also run gnuton "
                  "`rc` action if compatible.",
         tested="Not yet.",
         risks="Leak if rules not applied early; Router-mode only.",
         links=["Changelog-NG.txt (3004.388.8 killswitch)"]),

    dict(id="openvpn-client", title="OpenVPN Client", cat="VPN",
         modes="Router (WAN + VPN client)",
         status="stock+",
         what="Connect the router (or selected clients via VPN Director) to an OpenVPN server.",
         gnuton="Firmware VPN daemon (`openvpn`), web page `Advanced_OpenVPNClient_Content.asp`, "
                "routing via VPN Director.",
         deps="`openvpn` binary (present on stock), certs/configs in JFFS, routing rules.",
         franklin="Stock already has openvpn; expose gnuton's client page via bind-mounted httpd, "
                  "or run gnuton's openvpn with generated configs.",
         tested="openvpn binary present on stock; page loads via gnuton UI.",
         risks="Routing/killswitch logic lives in rc; VPN page may depend on rc helpers.",
         links=["www/Advanced_OpenVPNClient_Content.asp", "usr/sbin/openvpn"]),

    dict(id="openvpn-server", title="OpenVPN Server", cat="VPN",
         modes="Router",
         status="stock+",
         what="Run an OpenVPN server on the router for remote clients.",
         gnuton="Firmware openvpn server + cert generation; page `Advanced_VPN_OpenVPN.asp`.",
         deps="openvpn, certs, firewall/NAT, WAN.",
         franklin="Stock supports it; expose gnuton page. Cert generation may be gnuton-specific.",
         tested="openvpn present; page loads.",
         risks="Router-mode only.",
         links=["www/Advanced_VPN_OpenVPN.asp"]),

    dict(id="wireguard-client", title="WireGuard Client", cat="VPN",
         modes="Router",
         status="stock+",
         what="Connect to a WireGuard endpoint; route selected traffic via VPN Director.",
         gnuton="Kernel `wireguard.ko` + `wg` tool + web UI.",
         deps="`wireguard.ko` (module present on stock), `wg` tool, config.",
         franklin="Stock has wireguard module + wg; gnuton UI page. Note: enabling WG disables HW NAT.",
         tested="wireguard.ko present on stock; `wg` binary present.",
         risks="Disables hardware NAT acceleration; Router-mode.",
         links=["www/Advanced_WireguardClient_Content.asp", "usr/sbin/wg"]),

    dict(id="wireguard-server", title="WireGuard Server", cat="VPN",
         modes="Router",
         status="stock+",
         what="Run a WireGuard server on the router.",
         gnuton="wireguard.ko + wg + web UI (`Advanced_WireguardServer_Content.asp`).",
         deps="wireguard.ko, wg, keys, firewall.",
         franklin="Stock supports it; expose gnuton page.",
         tested="Module/tool present.",
         risks="Router-mode.",
         links=["www/Advanced_WireguardServer_Content.asp"]),

    dict(id="ipsec-vpn", title="IPSec VPN", cat="VPN",
         modes="Router",
         status="stock+",
         what="IPSec server (strongSwan) for site-to-site / remote clients.",
         gnuton="strongswan + web UI (`Advanced_VPN_IPSec.asp`).",
         deps="strongswan (stock), certs/PSK, firewall.",
         franklin="Stock supports it; expose gnuton page.",
         tested="IPSec pages present on stock.",
         risks="Router-mode.",
         links=["www/Advanced_VPN_IPSec.asp"]),

    dict(id="dns-director", title="DNS Director (DNSFilter)", cat="DNS",
         modes="Router (DHCP/DNS server)",
         status="planned",
         what="Per-client DNS redirection/filtering: force clients to specific DNS servers (or block) "
              "via iptables REDIRECT + dnsmasq.",
         gnuton="Merlin/gnuton `rc` + iptables REDIRECT (v4/v6) + dnsmasq; page `DNSDirector.asp`.",
         deps="iptables, dnsmasq, client list; Router mode.",
         franklin="Reimplement iptables REDIRECT rules + dnsmasq config in Franklin scripts; gnuton UI page.",
         tested="Not yet (Router-mode).",
         risks="AP mode has no local DHCP/DNS; depends on upstream.",
         links=["www/DNSDirector.asp"]),

    dict(id="dns-over-tls", title="DNS-over-TLS (DoT)", cat="DNS",
         modes="Router / AP",
         status="planned",
         what="Encrypt DNS queries to upstream resolvers using stubby/getdns or dnsmasq DoT.",
         gnuton="stubby/getdns, dnsmasq integration, DoT server presets; page `Advanced_System_Content.asp`.",
         deps="stubby/getdns (stock may have), dnsmasq, cert bundle.",
         franklin="Use Entware stubby/unbound or stock dnsmasq DoT; expose UI.",
         tested="Not yet.",
         risks="dnsmasq version support; IPv6 DoT blocking fixes in gnuton are userland/kernel mix.",
         links=["www/Advanced_System_Content.asp"]),

    dict(id="dnsmasq-custom", title="Custom dnsmasq config", cat="DNS",
         modes="Router / AP",
         status="stock+",
         what="Add custom dnsmasq options (hosts, upstreams, DHCP options).",
         gnuton="dnsmasq + `/jffs/configs/dnsmasq.conf.add`; web field.",
         deps="dnsmasq (stock), writable JFFS.",
         franklin="Stock supports `/jffs/configs/dnsmasq.conf.add` (verify); otherwise start Entware dnsmasq.",
         tested="dnsmasq present on stock; JFFS config path to verify.",
         risks="Stock may not read `/jffs/configs` (Merlin feature) — verify.",
         links=["usr/sbin/dnsmasq"]),

    dict(id="firewall-custom", title="Custom firewall / NAT rules", cat="Network",
         modes="Router",
         status="planned",
         what="Add iptables/nat rules (port forwarding beyond UI, custom NAT, marks).",
         gnuton="Merlin `/jffs/scripts/firewall-start`, `nat-start` hooks; iptables.",
         deps="iptables (stock), a boot hook (USB asusware.arm on stock).",
         franklin="Run rules from the USB boot hook (since /jffs/scripts is not honored on stock).",
         tested="USB asusware.arm hook verified; /jffs/scripts NOT honored on stock.",
         risks="Router-mode; rules reset on service restart — re-apply.",
         links=["docs/xt9-notes.md"]),

    dict(id="nat-acceleration", title="NAT acceleration (CTF/FA)", cat="Network",
         modes="Router",
         status="out-of-scope",
         what="Hardware cut-through forwarding / flow acceleration for WAN throughput.",
         gnuton="Broadcom driver/kernel built-in (BCM_ENET, pktflow, CTF).",
         deps="Kernel/driver — not a loadable module.",
         franklin="Cannot add via USB; requires kernel rebuild/flash. Note: WireGuard disables it.",
         tested="Config shows it built-in on stock; not modularizable.",
         risks="Firmware-level only.",
         links=["docs/kernel-feature-matrix.md"]),

    dict(id="cake-qos", title="Cake QoS", cat="QoS",
         modes="Router (WAN shaping)",
         status="tested",
         what="Modern bufferbloat-fighting qdisc (cake) for WAN traffic shaping.",
         gnuton="`sch_cake.ko` + QoS UI; per-model support.",
         deps="`sch_cake.ko` built for the exact kernel (4.19.183); tc.",
         franklin="Build `sch_cake.ko` from ASUS GPL, load at boot; expose UI.",
         tested="Built from ASUS GPL 4.19.183; insmod + `tc qdisc add dev br0 root cake` works (no crash).",
         risks="Router-mode for WAN shaping; module must match kernel; not persistent until boot hook.",
         links=["docs/xt9-kernel-notes.md"]),

    dict(id="adaptive-qos", title="Adaptive QoS / DPI", cat="QoS",
         modes="Router",
         status="research",
         what="ASUS/Trend Micro QoS with DPI classification (Adaptive QoS, Traffic Analyzer).",
         gnuton="`bwdpi` daemon + Broadcom DPI kernel (`BCM_DPI`) + signature DB; pages AdaptiveQoS_*.",
         deps="BCM_DPI module (modularizable per audit), bwdpi userspace, signatures.",
         franklin="Possible if BCM_DPI.ko + bwdpi + signatures can be supplied; audit says BCM_DPI modularizable.",
         tested="Audit: BCM_DPI modularizable; not yet built.",
         risks="Signature DB/service coupling; Router-mode.",
         links=["docs/kernel-feature-matrix.md"]),

    dict(id="traffic-monitor", title="Traffic Monitor", cat="Monitoring",
         modes="Router (WAN stats); AP limited",
         status="stock+",
         what="Realtime/history WAN traffic graphs, per-client stats.",
         gnuton="Redesigned pages using Chart.js; stats stored in JFFS.",
         deps="httpd + www; nvram/stats DB.",
         franklin="gnuton Traffic Monitor pages via bind-mounted httpd; data from stock daemons.",
         tested="gnuton pages load via :8088.",
         risks="Needs gnuton data paths; AP mode limited.",
         links=["www/Main_TrafficMonitor_realtime.asp"]),

    dict(id="qos-classification", title="QoS Classification / Stats", cat="QoS",
         modes="Router",
         status="research",
         what="Classify traffic and show upload/download per app/category.",
         gnuton="QoS daemon + DPI; page `QoS_Stats.asp`.",
         deps="bwdpi/DPI, tc marks.",
         franklin="Tied to DPI; see adaptive-qos.",
         tested="Page loads; data depends on DPI.",
         risks="Router-mode.",
         links=["www/QoS_Stats.asp"]),

    dict(id="sysinfo", title="Tools / Sysinfo", cat="Monitoring",
         modes="all",
         status="stock+",
         what="CPU, RAM, temperature graphs, uptime, interface stats.",
         gnuton="Redesigned Sysinfo page (`Tools_Sysinfo.asp`) with graphs.",
         deps="httpd + www; sysfs/proc.",
         franklin="gnuton Sysinfo page via bind-mounted httpd.",
         tested="gnuton sysinfo page loads (200).",
         risks="Low.",
         links=["www/Tools_Sysinfo.asp"]),

    dict(id="wifi-insight", title="WiFi Insight", cat="Wireless",
         modes="all (mesh/AP)",
         status="stock+",
         what="Wireless diagnostics: client RSSI, channel utilization, band info.",
         gnuton="`WiFi_Insight.asp` + wireless data from drivers/daemons.",
         deps="httpd + www; wl/dhd data.",
         franklin="gnuton page via bind-mounted httpd.",
         tested="Page loads (200).",
         risks="Some data may be model-specific.",
         links=["www/WiFi_Insight.asp"]),

    dict(id="wireless-survey", title="Wireless Survey", cat="Wireless",
         modes="all",
         status="stock+",
         what="Scan neighboring APs (channels, RSSI, security).",
         gnuton="`Advanced_Wireless_Survey.asp` + scan helper.",
         deps="wireless scan capability; httpd + www.",
         franklin="gnuton page via bind-mounted httpd.",
         tested="Page loads (200).",
         risks="Scan may interfere briefly; model-specific.",
         links=["www/Advanced_Wireless_Survey.asp"]),

    dict(id="network-tools", title="Network Tools", cat="Diagnostics",
         modes="all",
         status="stock+",
         what="Ping, traceroute, nslookup, Wake-on-LAN, netstat.",
         gnuton="`Main_Netstat_Content.asp`, `Main_WOL_Content.asp`, network tools pages.",
         deps="stock binaries + httpd + www.",
         franklin="gnuton pages via bind-mounted httpd.",
         tested="Pages present on stock.",
         risks="Low.",
         links=["www/Main_Netstat_Content.asp", "www/Main_WOL_Content.asp"]),

    dict(id="snmp", title="SNMP", cat="Services",
         modes="all",
         status="planned",
         what="SNMP agent for monitoring (net-snmp).",
         gnuton="`snmpd` (net-snmp) + `Advanced_SNMP_Content.asp`.",
         deps="`snmpd` binary (in gnuton /usr/sbin; not stock), config, boot hook.",
         franklin="Copy gnuton `snmpd` + deps, run from boot hook, expose page.",
         tested="gnuton has `snmpd`; not yet run.",
         risks="Library deps; low risk.",
         links=["usr/sbin/snmpd", "www/Advanced_SNMP_Content.asp"]),

    dict(id="tor", title="Tor", cat="Services",
         modes="Router",
         status="planned",
         what="Route selected traffic through Tor.",
         gnuton="`Tor` binary + `Advanced_TOR_Content.asp` + iptables rules.",
         deps="`Tor` (gnuton /usr/sbin), iptables, boot hook.",
         franklin="Run gnuton `Tor` + redirect rules; expose page.",
         tested="gnuton has `Tor`; not yet run.",
         risks="Router-mode; performance; rules re-apply.",
         links=["usr/sbin/Tor", "www/Advanced_TOR_Content.asp"]),

    dict(id="nfs", title="NFS server", cat="Storage",
         modes="all",
         status="planned",
         what="Export USB/attached storage over NFS.",
         gnuton="`nfsd`, `exportfs`, `mountd`, `portmap`, `statd` (gnuton /usr/sbin) + pages.",
         deps="kernel NFS support (check config), nfs-utils binaries, config.",
         franklin="Run gnuton NFS binaries if kernel supports NFS; else Entware.",
         tested="gnuton binaries present; kernel NFS support to verify.",
         risks="Kernel NFS may be absent; check config.",
         links=["usr/sbin/nfsd", "www/Advanced_AiDisk_NFS.asp"]),

    dict(id="samba-ftp-webdav", title="Samba / FTP / WebDAV (stock USB apps)", cat="Storage",
         modes="all",
         status="stock",
         what="File sharing over SMB/FTP/WebDAV from USB storage.",
         gnuton="Stock USB apps + gnuton fixes; `smbd`/`nmbd`, `vsftpd`/`ftpd`, WebDAV.",
         deps="Stock daemons present (`smbd`, `nmbd`).",
         franklin="Stock handles it; gnuton pages for config. No porting needed.",
         tested="smbd/nmbd present on stock; pages present.",
         risks="Firmware-level; keep stock.",
         links=["www/Advanced_AiDisk_samba.asp"]),

    dict(id="aidisk-nfs", title="AiDisk NFS", cat="Storage",
         modes="all",
         status="planned",
         what="NFS export config page for AiDisk.",
         gnuton="`Advanced_AiDisk_NFS.asp` + nfs daemons.",
         deps="see nfs feature.",
         franklin="gnuton page + NFS daemons.",
         tested="Page loads; daemons not yet.",
         risks="Depends on nfs feature.",
         links=["www/Advanced_AiDisk_NFS.asp"]),

    dict(id="amtm", title="amtm (terminal menu)", cat="Tools",
         modes="all",
         status="planned",
         what="Interactive terminal menu for add-ons (Entware, scripts, backups).",
         gnuton="`amtm` binary/script; installs/manages Entware and add-ons.",
         deps="Entware, shell, USB.",
         franklin="Run gnuton `amtm` or a Franklin equivalent; expose via SSH.",
         tested="gnuton has `amtm`.",
         risks="Designed for Merlin paths; may need adaptation.",
         links=["usr/sbin/amtm"]),

    dict(id="entware", title="Entware package ecosystem", cat="Packages",
         modes="all",
         status="planned",
         what="opkg package manager with thousands of binaries.",
         gnuton="Not bundled; users install Entware on USB.",
         deps="USB (not JFFS), `armv7sf-k3.2` repo.",
         franklin="Install Entware on USB; unset LD_LIBRARY_PATH for its binaries.",
         tested="Not yet installed.",
         risks="glibc conflicts; use unset LD_LIBRARY_PATH.",
         links=[]),

    dict(id="ipset", title="ipset", cat="Network",
         modes="all",
         status="tested",
         what="Kernel sets for efficient IP/MAC matching (used by Skynet, firewalls).",
         gnuton="`ip_set.ko` + `ipset` tool.",
         deps="`ip_set.ko` (+ hash types) built for 4.19.183; userspace `ipset`.",
         franklin="Build ip_set modules from ASUS GPL, load at boot; copy gnuton `ipset`.",
         tested="Built+loaded `ip_set`/`ip_set_hash_ip`; gnuton `ipset` create/add/list/destroy works.",
         risks="Module must match kernel; load before use.",
         links=["docs/xt9-kernel-notes.md", "usr/sbin/ipset"]),

    dict(id="tee", title="TEE (packet duplication)", cat="Network",
         modes="all",
         status="tested",
         what="Netfilter target that duplicates packets to a gateway (mirroring/IDS).",
         gnuton="`xt_TEE.ko` + `nf_dup_ipv4/6`.",
         deps="`xt_TEE.ko`, `nf_dup_ipv4/6.ko` (stock lacks NF_DUP).",
         franklin="Build/load modules from ASUS GPL; use with iptables.",
         tested="Built all three; insmod OK; `iptables -j TEE --gateway ...` add/list/del works.",
         risks="Module match; load order.",
         links=["docs/xt9-kernel-notes.md"]),

    dict(id="cron", title="cron / scheduled tasks", cat="Automation",
         modes="all",
         status="planned",
         what="Scheduled jobs (maintenance, watchdogs, reboots).",
         gnuton="Entware cron or stock `cru`; `Reboot schedule` UI.",
         deps="cron/cru, boot hook.",
         franklin="Use Entware cron or stock `cru` from boot hook.",
         tested="Not yet.",
         risks="Entware LD_LIBRARY_PATH; re-add jobs at boot.",
         links=[]),

    dict(id="custom-scripts", title="Custom scripts", cat="Automation",
         modes="all",
         status="tested",
         what="Run user scripts at boot / events.",
         gnuton="`/jffs/scripts/*` hooks (Merlin).",
         deps="On stock, `/jffs/scripts` is NOT honored (gnuton-only).",
         franklin="Use the USB `asusware.arm` hook instead; verified it runs at boot.",
         tested="`/jffs/scripts` hooks did not run on stock; USB asusware.arm works.",
         risks="USB must be present at boot.",
         links=["docs/xt9-notes.md"]),

    dict(id="jffs", title="JFFS partition", cat="Storage",
         modes="all",
         status="stock",
         what="Persistent writable storage for configs/scripts.",
         gnuton="JFFS enabled; scripts/configs stored there.",
         deps="Stock JFFS (present).",
         franklin="Use `/jffs` for Franklin configs/logs (stock).",
         tested="JFFS present and writable.",
         risks="None.",
         links=[]),

    dict(id="nvram-tools", title="NVRAM tools / config export", cat="System",
         modes="all",
         status="planned",
         what="Dump/restore nvram, export/import settings.",
         gnuton="nvram tooling + Settings backup/restore pages.",
         deps="`nvram` (stock), JFFS/USB.",
         franklin="Use stock nvram + gnuton backup pages; careful with unsupported vars.",
         tested="nvram present; some vars not settable/persisted (jffs2_scripts).",
         risks="nvram var support varies; don't rely on unsupported vars.",
         links=[]),

    dict(id="led-control", title="LED control", cat="System",
         modes="all",
         status="planned",
         what="Turn LEDs on/off, brightness.",
         gnuton="LED scripts/sysfs.",
         deps="LED sysfs entries.",
         franklin="Scripts over sysfs; expose UI optionally.",
         tested="Not yet.",
         risks="Model-specific LED paths.",
         links=[]),

    dict(id="disk-monitoring", title="Disk monitoring (smartmontools)", cat="Storage",
         modes="all",
         status="planned",
         what="SMART health, disk temperature.",
         gnuton="smartmontools via Entware.",
         deps="Entware smartmontools.",
         franklin="Entware; script + UI.",
         tested="Not present on stock.",
         risks="USB device path.",
         links=[]),

    dict(id="temperature-monitoring", title="Temperature monitoring", cat="Monitoring",
         modes="all",
         status="stock+",
         what="CPU/radio temperature sensors.",
         gnuton="Sysinfo graphs; sysfs.",
         deps="sysfs thermal.",
         franklin="Sysinfo page (gnuton) + sysfs.",
         tested="Sysinfo page loads.",
         risks="Model-specific sensors.",
         links=["www/Tools_Sysinfo.asp"]),

    dict(id="ddns", title="DDNS (custom providers)", cat="Network",
         modes="Router",
         status="planned",
         what="Dynamic DNS updates, incl. custom providers.",
         gnuton="inadyn/ddns-scripts; `Advanced_ASUSDDNS_Content.asp`.",
         deps="DDNS client (inadyn/Entware), WAN.",
         franklin="Stock DDNS or Entware ddns-scripts; gnuton page.",
         tested="ASUS DDNS page present.",
         risks="Router-mode.",
         links=["www/Advanced_ASUSDDNS_Content.asp"]),

    dict(id="ntp", title="NTP client/server", cat="System",
         modes="all",
         status="planned",
         what="Time sync and optional NTP server.",
         gnuton="ntp/ntpd; `Advanced_System_Content.asp`.",
         deps="ntpd (gnuton has ntp/ntpd; stock has ntpclient).",
         franklin="Use stock ntpclient or run gnuton ntpd; expose UI.",
         tested="Stock uses ntpclient; gnuton has ntpd.",
         risks="Low.",
         links=["usr/sbin/ntpd"]),

    dict(id="reboot-schedule", title="Reboot schedule", cat="Automation",
         modes="all",
         status="planned",
         what="Scheduled automatic reboots.",
         gnuton="cron + nvram `reboot_schedule`; UI on System page.",
         deps="cron, boot hook.",
         franklin="Stock `reboot_schedule` or cron job from boot hook.",
         tested="Page present.",
         risks="Low.",
         links=["www/Advanced_System_Content.asp"]),

    dict(id="aimesh", title="AiMesh", cat="Wireless",
         modes="Mesh (AiMesh router/node)",
         status="stock",
         what="ASUS mesh: multiple nodes with a single SSID, seamless roaming.",
         gnuton="Stock AiMesh + gnuton fixes; drivers/daemons.",
         deps="Stock firmware (mesh coordination, drivers).",
         franklin="Stock handles it; don't touch drivers. gnuton has mesh config UIs.",
         tested="Device is an AiMesh node; mesh works on stock.",
         risks="Firmware/driver-level; not portable.",
         links=["www/AiMesh.asp"]),

    dict(id="guest-network", title="Guest network", cat="Wireless",
         modes="Router / AP / Mesh",
         status="stock",
         what="Isolated guest SSIDs with optional intranet access.",
         gnuton="Stock guest network + gnuton fixes.",
         deps="hostapd/brctl (stock).",
         franklin="Stock handles it; gnuton UI.",
         tested="Guest network pages present.",
         risks="Firmware-level mostly.",
         links=["www/Guest_network.asp"]),

    dict(id="networkmap", title="Network Map / client list", cat="Monitoring",
         modes="all",
         status="tested",
         what="Connected clients (wired/wireless), names, IPs, mesh topology.",
         gnuton="`networkmap` daemon + httpd page `index.asp`/`device-map`.",
         deps="networkmap daemon; correct shm size (gnuton expects 198168 vs stock 197916).",
         franklin="Run gnuton networkmap (creates larger shm) or fix shm; gnuton UI reads it.",
         tested="Fixed shm size mismatch; `nmp_cache.js` populated; gnuton UI lists clients.",
         risks="Dual networkmap (watchdog) when swapping; shm size coupling.",
         links=["docs/firmware-comparison.md"]),

    dict(id="boot-hook", title="Boot hook (asusware.arm)", cat="System",
         modes="all",
         status="tested",
         what="Run Franklin at boot from a USB `asusware.arm` app folder.",
         gnuton="n/a (ns). Merlin uses `/jffs/scripts`.",
         deps="USB with `asusware.arm/`, `S*` init scripts, `Enabled: yes` control file.",
         franklin="Primary boot hook on stock; verified.",
         tested="Verified: S99xt9-log ran at boot.",
         risks="USB must be present; runs late (after services).",
         links=["docs/xt9-notes.md"]),

    dict(id="kernel-modules", title="Kernel modules (build recipe)", cat="Kernel",
         modes="all",
         status="tested",
         what="Add absent kernel features as `.ko` (Cake, TEE, ipset, ...).",
         gnuton="Ships modules built for its kernel.",
         deps="ASUS GPL tree (matching version), device `/proc/config.gz`, cross toolchain, `MODEL=XT9`.",
         franklin="Build from ASUS GPL + bcmkernel include path; load from boot hook.",
         tested="Cake, TEE, nf_dup, ipset built+loaded+functionally verified.",
         risks="Must match kernel 4.19.183 + config; not vanilla.",
         links=["docs/xt9-kernel-notes.md", "docs/kernel-feature-matrix.md"]),
]

TEMPLATE = """# {title}

**Category:** {cat}  
**Modes:** {modes}  
**Status:** `{status}`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

{what}

## How gnuton implements it

{gnuton}

## Requirements

{deps}

## Franklin approach

{franklin}

## Tested / verified

{tested}

## Risks / notes

{risks}

## Links / sources

{links}
"""

def main():
    os.makedirs(OUT, exist_ok=True)
    rows = []
    for f in FEATURES:
        path = os.path.join(OUT, f["id"] + ".md")
        links = "\n".join("- `%s`" % l for l in f["links"]) or "- (none yet)"
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(TEMPLATE.format(links=links, **{k: f[k] for k in
                     ("title","cat","modes","status","what","gnuton","deps","franklin","tested","risks")}))
        rows.append(f)

    # index
    idx = os.path.join(OUT, "README.md")
    with open(idx, "w", encoding="utf-8") as fh:
        fh.write("# Franklin feature plans\n\n")
        fh.write("One plan per gnuton/Merlin feature. Each plan explains what the feature\n")
        fh.write("does, how gnuton implements it, which modes it works in, what Franklin\n")
        fh.write("needs to recreate it, and what has been tested/verified.\n\n")
        fh.write("Status: `tested` = verified on the XT9; `stock` = handled by stock\n")
        fh.write("firmware; `modular`/`planned` = buildable/planned; `research` =\n")
        fh.write("needs investigation; `out-of-scope` = firmware-level only.\n\n")
        fh.write("| Feature | Category | Modes | Status | Plan |\n")
        fh.write("|---|---|---|---|---|\n")
        for f in rows:
            fh.write("| %s | %s | %s | `%s` | [%s](%s.md) |\n" % (
                f["title"], f["cat"], f["modes"], f["status"], f["id"], f["id"]))
    print("wrote %d feature files + README" % len(rows))

if __name__ == "__main__":
    main()
