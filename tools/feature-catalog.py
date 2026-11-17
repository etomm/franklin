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
         deps="gnuton `httpd`, the `/www` delta (427 of 956 pages/JS differ or are new), "
              "the 220 gnuton libs that differ from stock, `libovpn.so`, "
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
         what="Encrypt DNS queries to upstream resolvers using stubby or dnsmasq DoT.",
         gnuton="Configures the stock `stubby` binary and exposes DoT presets on "
                "`Advanced_System_Content.asp`.",
         deps="`stubby` (present in BOTH stock and gnuton), dnsmasq (stock), cert bundle.",
         franklin="Run the stock `stubby` with a Franklin-managed config from USB/JFFS and "
                  "expose the gnuton page. No Entware and no extra binary needed.",
         tested="`usr/sbin/stubby` confirmed in the stock rootfs; UI wiring not tested.",
         risks="dnsmasq/stubby version differences; IPv6 DoT blocking fixes in gnuton are a "
               "userland/kernel mix.",
         evidence="gnuton-feature (config/UI layer): `stubby` exists in BOTH rootfs, so the "
                  "provider is stock; only the page/config is gnuton's — no Entware involved.",
         links=["www/Advanced_System_Content.asp"]),

    dict(id="dnsmasq-custom", title="Custom dnsmasq config", cat="DNS",
         modes="Router / AP",
         status="stock+",
         what="Add custom dnsmasq options (hosts, upstreams, DHCP options).",
         gnuton="dnsmasq + `/jffs/configs/dnsmasq.conf.add`; web field.",
         deps="dnsmasq (stock), writable JFFS.",
         franklin="Stock `dnsmasq` with a Franklin-managed config fragment applied from the "
                  "boot hook (Merlin's `/jffs/configs` path is not honored by stock — verify).",
         tested="dnsmasq present on stock; JFFS config path to verify.",
         risks="Stock may not read `/jffs/configs` (Merlin feature) — verify before relying on it.",
         evidence="stock: `usr/sbin/dnsmasq` present in BOTH rootfs; no Entware package needed.",
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
         gnuton="Ships `nfsd`, `exportfs`, `mountd`, `portmap`, `statd` and the kernel modules "
                "`fs/nfsd/nfsd.ko`, `fs/nfs/nfs.ko`, `exportfs.ko`, `lockd.ko`, `sunrpc.ko` "
                "(all present only in gnuton's module tree).",
         deps="`nfsd.ko`/`nfs.ko`/`exportfs.ko`/`lockd.ko`/`sunrpc.ko` built for 4.19.183 (stock "
              "config has no CONFIG_NFS* at all), gnuton NFS userspace binaries, `nfsd` startup "
              "from the boot hook, `/etc/exports` on USB/JFFS.",
         franklin="Build the NFS modules with the kernel-module recipe, load them from the boot "
                  "hook, run gnuton's `rpcbind`/`nfsd`/`exportfs` from USB, and expose the gnuton "
                  "page.",
         tested="gnuton-only modules and binaries confirmed; stock XT9 config has no NFS entries, "
                "so modules must be built (not yet done).",
         risks="Two layers must be supplied (kernel modules + userspace); stock cannot serve NFS "
               "on its own. Router/AP mode irrelevant, but USB storage must be mounted first.",
         evidence="gnuton-feature: `nfsd.ko`/`nfs.ko`/`exportfs.ko` and `usr/sbin/nfsd` exist ONLY "
                  "in gnuton; stock's kernel config has no CONFIG_NFS_FS/NFSD.",
         links=["usr/sbin/nfsd", "www/Advanced_AiDisk_NFS.asp", "docs/kernel-feature-matrix.md"]),

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
         what="Interactive terminal menu for add-ons: it can install/manage Entware, scripts "
              "and backup jobs.",
         gnuton="Ships the third-party `amtm` script (by thelonelycoder) in `/usr/sbin`. It is "
                "not a gnuton/Merlin invention and it is not an Entware package either.",
         deps="Shell + USB. Entware is something amtm *manages*, not something it needs.",
         franklin="Ship the same `amtm` script from USB and run it over SSH. If Entware is "
                  "absent, amtm still starts; installing Entware is one of its menu entries.",
         tested="`usr/sbin/amtm` exists only in the gnuton rootfs (bundled third-party).",
         risks="Assumes Merlin paths (`/jffs/scripts`, `cru`); some menu entries may need "
               "adaptation on stock.",
         evidence="gnuton-feature (bundled third-party): `amtm` is present ONLY in gnuton's "
                  "rootfs, but it is a third-party script, not gnuton code.",
         links=["usr/sbin/amtm"]),

    dict(id="entware", title="Entware package ecosystem", cat="Packages",
         modes="all",
         status="planned",
         what="opkg package manager with thousands of prebuilt binaries. This is a "
              "separate third-party project (Entware), NOT part of gnuton/Merlin and "
              "NOT distributed with it.",
         gnuton="gnuton does not bundle Entware and ships no `opkg`. Merlin's docs only point "
                "users to it as an optional add-on source, installed separately on USB.",
         deps="USB (not JFFS), `armv7sf-k3.2` repo, boot hook to set up its paths.",
         franklin="Franklin-specific provider. Packages that only exist there are tagged "
                  "`entware-package` (smartmontools, aria2, tcpdump, ...), never "
                  "`gnuton-feature`. It does NOT replace gnuton binaries (httpd, libwebapi, "
                  "libovpn) nor kernel modules (built from the ASUS GPL).",
         tested="Not yet installed. Verified that gnuton ships no opkg, no smartctl, no "
                "hdparm, no aria2c and no tcpdump.",
         risks="Its binaries are built for its own toolchain/libc; use unset LD_LIBRARY_PATH. "
               "Cannot provide gnuton-patched binaries or kernel modules.",
         evidence="franklin-feature: `opkg`, `smartctl`, `aria2c` and `tcpdump` are in NEITHER "
                  "rootfs, so anything requiring them is an Entware package, not gnuton.",
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
         status="stock",
         what="Scheduled jobs (maintenance, watchdogs, reboots).",
         gnuton="Uses the stock `crond`/`cru` and adds the `crontab` command; ships no cron "
                "daemon of its own.",
         deps="`crond`/`cru` (stock).",
         franklin="Schedule jobs with stock `cru` from the boot hook and re-add them at boot "
                  "(RAM-based). No Entware and no daemon to install.",
         tested="`usr/sbin/crond` and `usr/sbin/cru` present in BOTH rootfs; gnuton adds only "
                "`usr/bin/crontab`.",
         risks="Jobs live in RAM and vanish on reboot; `/jffs/scripts` is not honored on stock.",
         evidence="stock: `crond` and `cru` exist in BOTH rootfs (`crontab` is gnuton-only "
                  "convenience), so cron is a stock feature.",
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
         what="Persistent writable storage. Stock has JFFS; gnuton uses it for "
              "`/jffs/configs`, `/jffs/scripts`, VPN Director rules, certs and the "
              "Traffic Monitor DB.",
         gnuton="gnuton/Merlin stores persistent configs in `/jffs` and runs its "
                "`/jffs/scripts` hooks (a Merlin feature).",
         deps="Stock JFFS (always present). Not a build dependency.",
         franklin="Use `/jffs` for persistent configs/logs, like gnuton. But `/jffs/scripts` "
                  "hooks are NOT honored on stock; the boot hook lives on USB and can "
                  "sync/apply config to `/jffs` at boot.",
         tested="JFFS present and writable; `/jffs/scripts` hooks did not run on stock.",
         risks="JFFS is stock (nothing to build). Don't rely on `/jffs/scripts` for boot on stock.",
         links=["docs/xt9-notes.md"]),

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
         what="SMART health and disk temperature for USB/attached drives.",
         gnuton="Not provided: gnuton ships no `smartctl`. Merlin/gnuton users install "
                "smartmontools from Entware.",
         deps="Entware `smartmontools` (`smartctl`), USB storage, boot hook to schedule checks.",
         franklin="Franklin-specific: install smartmontools from Entware, run `smartctl -H` "
                  "from cron/boot hook and surface it on a page.",
         tested="`smartctl` is in NEITHER rootfs, so neither stock nor gnuton can do SMART.",
         risks="USB bridge must pass SMART through; Entware binaries need "
               "`unset LD_LIBRARY_PATH`.",
         evidence="entware-package: `smartctl` absent from BOTH rootfs; this is an Entware "
                  "feature that Franklin integrates, not a gnuton feature.",
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
         status="stock+",
         what="Dynamic DNS updates, including custom providers.",
         gnuton="Stock `inadyn` plus gnuton's `sbin/ddns_custom_updated` helper and the "
                "`Advanced_ASUSDDNS_Content.asp` page.",
         deps="`inadyn` (stock), WAN, provider credentials.",
         franklin="Stock DDNS covers ASUS + provider list; add custom providers with gnuton's "
                  "helper (gnuton-only binary) from the boot hook. No Entware needed.",
         tested="`inadyn` present in BOTH rootfs; `ddns_custom_updated` is gnuton-only.",
         risks="Router-mode only; credentials on USB/JFFS with tight permissions.",
         evidence="stock + gnuton delta: `inadyn` is in BOTH rootfs (stock DDNS works); only "
                  "`ddns_custom_updated` is gnuton-only, so custom providers are the delta.",
         links=["www/Advanced_ASUSDDNS_Content.asp"]),

    dict(id="ntp", title="NTP client/server", cat="System",
         modes="all",
         status="planned",
         what="Time sync and optional NTP server.",
         gnuton="Ships `ntpd` (gnuton-only) and `ntpd_synced`; stock only has `ntpclient`.",
         deps="`ntpd` (gnuton binary), boot hook to start it.",
         franklin="Use stock `ntpclient` for time sync, and run gnuton's `ntpd` from USB only "
                  "if an NTP server is wanted.",
         tested="`usr/sbin/ntpd` gnuton-only; `usr/sbin/ntpclient` and `sbin/ntp` stock-only.",
         risks="Low. Two time daemons must not fight over the clock.",
         evidence="gnuton-feature: `ntpd` exists ONLY in gnuton (stock has `ntpclient`), so the "
                  "NTP *server* is a gnuton addition.",
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
         what="ASUS mesh: multiple nodes with a single SSID, seamless roaming, and a "
              "controller that pushes configuration to every node.",
         gnuton="Stock AiMesh only: gnuton ships the same closed mesh stack (amas*, "
                "cfg_server/cfg_client, bsd, dhd.ko) and adds nothing to it.",
         deps="Stock firmware: mesh agent, config-sync daemons and wireless drivers. Nothing "
              "Franklin can build or replace.",
         franklin="Stock handles it and Franklin must stay out of the way: no patching of "
                  "amas/cfg_server, no nvram-only state, and no touching build/version "
                  "identity. On a node, settings are owned by the controller.",
         tested="Device is an AiMesh node in AP mode on stock; mesh works. Both rootfs "
                "contain identical mesh components, so there is no gnuton delta to port.",
         risks="Firmware/control-plane level, not portable. Config pushed by cfg_server can "
               "overwrite anything Franklin sets in nvram. All nodes must run the same build — "
               "see docs/mesh-and-firmware-compatibility.md.",
         evidence="stock: `amas*`, `cfg_server`, `cfg_client`, `bsd`, `dhd.ko` and the AiMesh "
                  "pages exist in BOTH rootfs; no gnuton-only mesh file was found by "
                  "tools/parity-audit.py.",
         links=["docs/mesh-and-firmware-compatibility.md", "docs/parity-audit.md"]),

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
         gnuton="`networkmap` daemon + httpd page `index.asp`/`device-map`; the daemon also "
                "writes `/jffs/nmp_cl_json.js` with the client list.",
         deps="gnuton `networkmap` binary; `franklin-mount` (to bind it over the stock path); "
              "shm key 0x3e9 sized 198168 (gnuton) instead of 197916 (stock).",
         franklin="Workaround: bind gnuton networkmap over `/usr/sbin/networkmap`, clear the "
                  "stale shm segment, start the daemon (stock's service actions are no-ops) and "
                  "verify the 198168 layout before restarting httpd.",
         tested="Verified on the XT9: shm 0x3e9 = 198168, gnuton daemon running, "
                "`/jffs/nmp_cl_json.js` rewritten with 14 KB of clients.",
         risks="Stock allocates a smaller struct, so mixing binaries breaks the list; the old "
               "shm segment must be removed or the daemon reuses the wrong size.",
         evidence="workaround: stock's networkmap allocates the smaller struct (197916 vs "
                  "198168), so the gnuton UI cannot read its client table; replacing the "
                  "daemon binary is the only fix that keeps the UI's layout.",
         links=["docs/firmware-comparison.md"]),

    dict(id="boot-hook", title="Boot hook (asusware.arm)", cat="System",
         modes="all",
         status="tested",
         what="Run Franklin at boot from a USB `asusware.arm` app folder.",
         gnuton="n/a — gnuton/Merlin run `/jffs/scripts/*` hooks instead; stock ignores them, "
                "so Franklin uses the USB `asusware.arm` app hook.",
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

    # --- plans added so every gnuton-feature-parity row links somewhere real ---
    dict(id="vlan-iptv", title="VLAN / IPTV port tagging (ethswctl, softswitch)", cat="Network",
         modes="Router / AP (wired switch config)",
         status="planned",
         what="Per-port VLAN tagging and softswitch map: ISP IPTV on one port, internet on "
              "another, and VLAN segmentation of the wired switch.",
         gnuton="Merlin `rc` programs the switch map through `ethswctl`/softswitch helpers; "
                "the gnuton/Merlin UI exposes it as VLAN/IPTV config.",
         deps="`ethswctl` (present in stock too), switch driver support; wired ports only.",
         franklin="Drive `ethswctl` from the USB boot hook (sequence verified on the XT9); "
                  "no rc swap needed.",
         tested="Sequence verified on XT9; not yet wired to boot.",
         risks="Switch map is model-specific; a wrong map can cut off LAN/WAN access. "
               "Wireless clients are unaffected by VLAN tagging.",
         evidence="gnuton-feature: no VLAN/IPTV page in either rootfs, but Merlin `rc` + "
                  "`ethswctl` implement it; stock exposes no UI, so Franklin scripts it.",
         links=["docs/xt9-notes.md"]),

    dict(id="bridge-management", title="Bridge management (brctl)", cat="Network",
         modes="all",
         status="stock",
         what="Inspect/manage the soft bridges that join LAN ports, wireless interfaces and "
              "guest networks (br0, br1, ethx, wl0.x).",
         gnuton="Merlin `rc` uses `brctl` for bridge add/del/list; hooks let scripts adjust "
                "bridges at boot.",
         deps="`brctl` (stock).",
         franklin="Use stock `brctl` from the boot hook for extra bridges/ports; stock already "
                  "manages the default bridge set.",
         tested="`brctl show`/`addif`/`delif` present and working on stock.",
         risks="Removing the wrong port from br0 drops connectivity; re-apply after service restart.",
         evidence="stock: `brctl` is in stock and no bridge page differs between stock and "
                  "gnuton rootfs.",
         links=[]),

    dict(id="igmp-snooping", title="IGMP snooping / multicast", cat="Network",
         modes="Router / AP",
         status="out-of-scope",
         what="Multicast group management for IPTV/streaming so multicast is not flooded to "
              "every port and wireless client.",
         gnuton="Kernel bridge multicast snooping plus switch-driver multicast tables; toggled "
                "through nvram by `rc`.",
         deps="Kernel bridge IGMP snooping support and switch-driver multicast tables.",
         franklin="Mostly firmware/driver-level: only nvram/sysfs toggles are reachable from "
                  "userspace; full support needs a kernel switch-driver change.",
         tested="Not tested; classified from kernel config/audit.",
         risks="Kernel/driver-level; may be partially toggleable via nvram but not fully ported.",
         evidence="stock/driver-level: no IGMP/multicast page in either rootfs and no gnuton-only "
                  "binary; identical in stock.",
         links=["docs/kernel-feature-matrix.md"]),

    dict(id="cifs-client", title="CIFS mount (client)", cat="Storage",
         modes="all",
         status="planned",
         what="Mount a remote SMB/CIFS share on the router (e.g. for backups or media).",
         gnuton="gnuton ships `fs/cifs/cifs.ko` in its module tree (kernel 4.1.52), so the "
                "filesystem is available to it; mounting is done with busybox/Entware tools.",
         deps="`cifs.ko` built for 4.19.183 from the ASUS GPL (stock kernel has no CONFIG_CIFS "
              "at all), a mount helper (`mount -t cifs` or Entware cifs-utils), boot hook to "
              "mount at boot.",
         franklin="Build `cifs.ko` with the kernel-module recipe, load it from the boot hook and "
                  "mount the share; credentials live on USB/JFFS.",
         tested="gnuton-only module confirmed (`lib/modules/4.1.52/.../fs/cifs/cifs.ko`); stock "
                "XT9 config has no CONFIG_CIFS entry, so the module must be built and is not yet.",
         risks="Needs a matching kernel module; credentials must live on USB/JFFS with tight perms.",
         evidence="gnuton-feature: `cifs.ko` exists ONLY in the gnuton module tree and stock's "
                  "4.19.183 config has no CIFS support, so stock cannot mount CIFS and gnuton can.",
         links=["docs/kernel-feature-matrix.md", "docs/xt9-kernel-notes.md"]),

    dict(id="dhcp-leases", title="DHCP static leases / custom config", cat="DNS",
         modes="Router (DHCP server)",
         status="stock",
         what="Pin IP addresses to MACs and add custom DHCP options for the LAN.",
         gnuton="`dnsmasq` `dhcp-host` entries generated by `rc` from nvram; custom "
                "`dnsmasq.conf.add` on Merlin.",
         deps="`dnsmasq` (stock), DHCP server enabled, writable `/jffs` for extra fragments.",
         franklin="Stock DHCP + static leases work; extra options go through dnsmasq-custom.",
         tested="`Advanced_DHCP_Content.asp` present on stock and gnuton (both contain the "
                "static-lease fields).",
         risks="AP mode has no local DHCP server — depends on the main router.",
         evidence="stock: `Advanced_DHCP_Content.asp` and `Main_DHCPStatus_Content.asp` exist with "
                  "the same static-lease support in BOTH rootfs.",
         links=[]),

    dict(id="disk-spindown", title="Disk spindown / power management", cat="Storage",
         modes="all",
         status="stock",
         what="Spin down idle USB/attached disks and control APM/AAM to reduce noise and wear.",
         gnuton="Stock `rc` handles disk spindown; the setting is on the System page.",
         deps="Stock firmware (no extra binary needed).",
         franklin="Stock handles it; Franklin only needs to not keep disks awake with indexing.",
         tested="`spindown` is present in `Advanced_System_Content.asp` in both stock and gnuton.",
         risks="Aggressive spindown shortens some drives' life; USB bridges may ignore APM.",
         evidence="stock: the spindown control exists in `Advanced_System_Content.asp` in BOTH "
                  "rootfs; neither ships `hdparm`.",
         links=[]),

    dict(id="ssh-access", title="SSH access (dropbear / openssh)", cat="System",
         modes="all",
         status="stock",
         what="Remote shell access, key-based logins, and optional full OpenSSH.",
         gnuton="Stock `dropbear` + Merlin tweaks; gnuton adds `scp` only.",
         deps="`dropbear` (stock), USB or `/jffs` for `authorized_keys`.",
         franklin="Stock dropbear + authorized_keys on USB/JFFS; Entware openssh only if sftp/scp "
                  "is required.",
         tested="dropbear works with key auth from this workstation; no scp/sftp (use `cat >`).",
         risks="Exposing SSH to WAN is unsafe; keys must be deployed before disabling passwords.",
         evidence="stock: `usr/sbin/dropbear` is in both rootfs (gnuton only adds `usr/bin/scp`).",
         links=["docs/xt9-notes.md"]),

    dict(id="syslog", title="System log / remote syslog", cat="Monitoring",
         modes="all",
         status="stock",
         what="Local and remote logging of kernel and daemon messages.",
         gnuton="Stock `syslogd`/`klogd` + `logread`; remote server config on the Log page.",
         deps="`syslogd`/`klogd` (stock), USB for persistence.",
         franklin="Stock logging; forward to a remote collector and persist logs to USB from the "
                  "boot hook if wanted.",
         tested="`logread`/`dmesg` available; log persistence not configured yet.",
         risks="Flash wear if logs are written to JFFS; prefer USB.",
         evidence="stock: `sbin/syslogd` and `Main_LogStatus_Content.asp` exist in both rootfs.",
         links=[]),

    dict(id="aiprotection", title="AiProtection (Trend Micro)", cat="Security",
         modes="Router",
         status="out-of-scope",
         what="Trend Micro security suite: malicious-site blocking, IPS, infected-device "
              "blocking, parental filtering.",
         gnuton="Stock ASUS/Trend Micro feature (not gnuton-specific); `bwdpi` + Broadcom DPI "
                "(`BCM_DPI`) + Trend Micro signatures.",
         deps="`BCM_DPI` kernel module, proprietary `bwdpi` userspace, Trend Micro signature DB "
              "and licensing/cloud service.",
         franklin="Not portable: the daemon and signatures are proprietary and licensed. Stock "
                  "keeps providing it; Franklin must not disturb it.",
         tested="Not tested; classified from firmware contents.",
         risks="Licensed/proprietary service — cannot be redistributed via Franklin.",
         evidence="stock/proprietary: all 11 `AiProtection_*.asp` pages exist in BOTH rootfs; it "
                  "is an ASUS/Trend Micro feature gnuton inherits.",
         links=["docs/firmware-comparison.md"]),

    dict(id="ap-modes", title="AP / Bridge / Repeater / Media bridge modes", cat="Wireless",
         modes="AP / Router / Mesh",
         status="stock",
         what="Operating modes of the box: wireless router, access point, repeater, media bridge.",
         gnuton="Stock `rc` + `nvram` mode variables; drivers do the work.",
         deps="Stock firmware and wireless drivers.",
         franklin="Stock handles it; Franklin must not break mode switching and should detect AP "
                  "mode (many features need Router mode).",
         tested="Device runs as an AiMesh node in AP mode on stock.",
         risks="Franklin features that need WAN/DHCP/firewall do not work in AP mode.",
         evidence="stock: `Advanced_OperationMode_Content.asp` is byte-for-byte present in both "
                  "rootfs and mentions repeater/bridge/media.",
         links=["docs/xt9-notes.md"]),

    dict(id="cloud-sync", title="Cloud sync (Dropbox, etc.)", cat="Storage",
         modes="all",
         status="out-of-scope",
         what="Sync USB storage folders to a cloud provider.",
         gnuton="Stock ASUS Cloud Sync client (proprietary, account-bound).",
         deps="ASUS cloud client + account service.",
         franklin="Proprietary client; a substitute would be Entware `rclone` as a "
                  "Franklin-specific add-on, not a gnuton port.",
         tested="Not tested.",
         risks="Proprietary; use rclone if needed.",
         evidence="stock/proprietary: `cloud_sync.asp` (with Dropbox strings) exists in BOTH "
                  "rootfs.",
         links=[]),

    dict(id="firmware-upgrade", title="Firmware upgrade helpers", cat="System",
         modes="all",
         status="stock",
         what="Check for and apply ASUS firmware updates, plus the upgrade UI.",
         gnuton="Stock `webs_upgrade`/`rc` path; gnuton only changes the update source "
                "(`sbin/firmware_webs_update` is gnuton-only).",
         deps="Stock upgrade tooling, signed images.",
         franklin="Must stay stock: Franklin must never interfere with the upgrade path or it can "
                  "brick the device. Document compatibility per firmware version instead.",
         tested="Stock upgrade path untouched by Franklin.",
         risks="Never modify the upgrade flow; overrides must be re-applied after each upgrade.",
         evidence="stock: `Advanced_FirmwareUpgrade_Content.asp` exists in both rootfs; the only "
                  "gnuton difference is its own update-channel script.",
         links=[]),

    dict(id="ipv6", title="IPv6 (native, 6in4, 6to4, 6rd)", cat="Network",
         modes="Router",
         status="stock",
         what="IPv6 connectivity and addressing for the LAN.",
         gnuton="Stock IPv6 stack (`odhcp6c`, IPv6 firewall) + gnuton fixes.",
         deps="Stock kernel IPv6 (built-in) and userspace.",
         franklin="Stock handles it; Franklin firewall/QoS rules must be kept IPv4/IPv6 "
                  "symmetric where relevant.",
         tested="IPv6 present on stock; AP mode inherits from the main router.",
         risks="Router-mode for prefix delegation; IPv6 firewall rules easy to get wrong.",
         evidence="stock: `Advanced_IPv6_Content.asp`, `Advanced_IPv61_Content.asp`, "
                  "`Main_IPV6Status_Content.asp` and `odhcp6c` exist in BOTH rootfs.",
         links=[]),

    dict(id="mac-filter", title="MAC filter", cat="Wireless",
         modes="all",
         status="stock",
         what="Allow/deny wireless or wired clients by MAC address.",
         gnuton="Stock `rc` generates hostapd ACLs/`ebtables` rules from the MAC list.",
         deps="Stock hostapd/ebtables.",
         franklin="Stock handles it; nothing to port.",
         tested="Stock MAC filter UI present.",
         risks="Not a security boundary on its own (MAC spoofing); keep stock implementation.",
         evidence="stock: `ebtables` exists in both rootfs and the filter is configured from the "
                  "stock wireless pages (no gnuton-only page/binary).",
         links=[]),

    dict(id="parental-controls", title="Parental controls", cat="Security",
         modes="Router",
         status="stock",
         what="Per-device internet scheduling/blocking and (with AiProtection) content "
              "filtering.",
         gnuton="Stock `ParentalControl.asp` + `rc`; content categories come from `bwdpi`.",
         deps="Stock scheduler/iptables; content filtering needs AiProtection.",
         franklin="Time-based blocking stays stock; if Franklin needs it on a different rule set, "
                  "use iptables + cron from the boot hook. Category filtering is proprietary.",
         tested="Not tested (AP mode: scheduling lives on the main router).",
         risks="Router-mode; content categories need the proprietary DPI engine.",
         evidence="stock: `ParentalControl.asp` exists in BOTH rootfs; only the content "
                  "categories depend on proprietary DPI.",
         links=["aiprotection.md"]),

    dict(id="port-forwarding", title="Port forwarding / virtual server / DMZ", cat="Network",
         modes="Router",
         status="stock",
         what="Expose internal services on the WAN, including a DMZ host and UPnP/NAT-PMP.",
         gnuton="Stock `rc` builds `iptables` DNAT rules from nvram/UPnP.",
         deps="Stock `iptables` NAT and `miniupnpd`.",
         franklin="Stock handles it; Franklin firewall rules must not flush the NAT table "
                  "(or must re-add forwardings).",
         tested="Stock pages present; not exercised.",
         risks="Router-mode only; a careless `iptables -F` breaks forwardings until restart.",
         evidence="stock: `Advanced_VirtualServer_Content.asp` and `miniupnpd` exist in BOTH "
                  "rootfs.",
         links=["firewall-custom.md"]),

    dict(id="traffic-analyzer", title="Traffic Analyzer / bandwidth monitor", cat="Monitoring",
         modes="Router",
         status="out-of-scope",
         what="Historical per-client/per-app bandwidth statistics and charts.",
         gnuton="Stock ASUS Traffic Analyzer page fed by `bwdpi`/DPI classification.",
         deps="DPI (`BCM_DPI` + `bwdpi`) for app classification; `rstats` for per-client totals.",
         franklin="Per-client byte counters are feasible; per-app classification is tied to "
                  "proprietary DPI. Traffic Monitor (a different, gnuton feature) covers the "
                  "simple graphs.",
         tested="Not tested.",
         risks="App-level stats need AiProtection; keep expectations at per-interface/per-client.",
         evidence="stock/proprietary: `TrafficAnalyzer_Statistic.asp` exists in BOTH rootfs; the "
                  "gnuton-only Traffic Monitor pages are a separate feature.",
         links=["adaptive-qos.md"]),

    dict(id="usb-modem", title="USB modem (3G/4G)", cat="Network",
         modes="Router",
         status="stock",
         what="Failover or primary WAN over a USB cellular modem.",
         gnuton="Stock `rc` WAN failover + modem helpers.",
         deps="Stock USB modem support and the modem's serial/PPP drivers in the kernel.",
         franklin="Stock handles it; Franklin must not disturb WAN failover ordering.",
         tested="Not tested (no modem available).",
         risks="Driver/modem-specific; Router-mode.",
         evidence="stock: `Advanced_Modem_Content.asp` exists in BOTH rootfs.",
         links=[]),

    dict(id="wireless-tuning", title="Wireless tuning (band steering, Smart Connect, WPS)", cat="Wireless",
         modes="all (mesh/AP)",
         status="stock",
         what="Radio parameters, band steering/Smart Connect, WPS, channel and width control.",
         gnuton="Stock `rc` + `wl`/`nvram` radio settings; drivers handle the rest.",
         deps="Stock wireless drivers and `wl` tooling.",
         franklin="Stock handles it; Franklin may read radio state via `wl` for monitoring but "
                  "should not fight the drivers.",
         tested="Stock wireless pages present; device is a mesh node on stock.",
         risks="Driver-level; bad radio settings can drop all clients.",
         evidence="stock: `Advanced_Wireless_Content.asp`, `Advanced_Smart_Connect.asp`, "
                  "`Advanced_WWPS_Content.asp` exist in BOTH rootfs.",
         links=[]),

    dict(id="download-manager", title="Download manager (aria2)", cat="Storage",
         modes="all",
         status="planned",
         what="Background HTTP/FTP/BitTorrent downloads to attached storage.",
         gnuton="Not bundled: gnuton ships no `aria2`; users install it (usually from Entware).",
         deps="`aria2` binary (Entware), storage, boot hook to start it.",
         franklin="Franklin addition: install aria2 (Entware) and supervise it from the boot hook. "
                  "Not a gnuton port.",
         tested="Not yet.",
         risks="Third-party binary; watch write wear and permissions on the share.",
         evidence="franklin-feature: no `aria2` in the gnuton rootfs (checked `usr/bin`, "
                  "`usr/sbin`, `bin`, `sbin`).",
         links=[]),

    dict(id="media-server", title="Media server (minidlna)", cat="Storage",
         modes="all",
         status="stock",
         what="DLNA/UPnP media server for TVs and consoles, indexing media on USB storage.",
         gnuton="Stock `minidlna` daemon + `rc` management.",
         deps="Stock `minidlna` (`/usr/sbin/minidlna`).",
         franklin="Stock handles it; Franklin only needs to not break its config/DB paths.",
         tested="`/usr/sbin/minidlna` present on stock.",
         risks="Indexing a large library is slow and I/O heavy on USB.",
         evidence="stock: `usr/sbin/minidlna` exists in BOTH rootfs.",
         links=[]),

    dict(id="time-machine", title="Time Machine (AFP) backup", cat="Storage",
         modes="all",
         status="stock",
         what="macOS Time Machine backups to a shared disk (AFP or SMB).",
         gnuton="Stock `netatalk`/SMB support configured by `rc`.",
         deps="Stock AFP/SMB support and a writable share.",
         franklin="Stock handles it; ensure Franklin does not alter share permissions or the "
                  "backup sparsebundle path.",
         tested="`Advanced_TimeMachine.asp` present on stock.",
         risks="AFP is deprecated by Apple in favour of SMB; disk space grows quickly.",
         evidence="stock: `Advanced_TimeMachine.asp` exists in BOTH rootfs.",
         links=[]),

    dict(id="franklin-mount", title="franklin-mount (mount(2) helper) — workaround", cat="System",
         modes="all",
         status="tested",
         what="A ~20 line static binary that performs mount(2)/umount(2) directly, used to "
              "mount over paths on the read-only squashfs root.",
         gnuton="n/a: gnuton ships its own httpd in the image, so it never has to mount over "
                "the stock rootfs.",
         deps="Cross compiler at build time (arm-linux-gnueabi-gcc); nothing at runtime.",
         franklin="Workaround for an ASUS restriction: busybox `mount` rejects any target on "
                  "the read-only squashfs (/www, /usr/sbin/httpd) with "
                  "\"Invalid mount path\". The kernel allows it; this helper proves it.",
         tested="Verified on the XT9: bind over /www, bind over /usr/sbin/httpd, and the full "
                "overlay + bind chain, each umounted back to stock.",
         risks="Static ARM binary; must be rebuilt with the same cross compiler. Only used for "
               "mounts Franklin owns.",
         evidence="workaround: needed because the stock mount tool refuses rootfs targets; the "
                  "kernel accepts them (tested).",
         links=["docs/build-architecture.md"]),

    dict(id="overlayfs", title="overlayfs modules (overlay.ko + exportfs.ko) — workaround", cat="Kernel",
         modes="all",
         status="tested",
         what="Adds overlayfs to stock, so gnuton's pages can be layered over the stock /www "
              "instead of replacing the whole tree.",
         gnuton="n/a: gnuton's kernel ships overlayfs-capable config and never needs it for the "
                "UI, because its /www is simply part of the firmware.",
         deps="`exportfs.ko` and `overlay.ko` built from the ASUS GPL for 4.19.183.",
         franklin="Build both modules with the kernel-module recipe; load at boot; the web UI "
                  "overlay uses a lowerdir stack (gnuton tree over stock) with the upper on USB.",
         tested="Built from the ASUS GPL (121 KB + 7.6 KB) and verified on the XT9: overlay over "
                "the read-only /www, copy-up on write, whiteouts, clean umount.",
         risks="Stock has CONFIG_OVERLAY_FS unset, so this is an out-of-tree addition; upperdir "
               "lives on the USB and receives runtime writes.",
         evidence="workaround: kernel capability stock lacks (CONFIG_OVERLAY_FS not set), added "
                  "the same way as cake/TEE; verified end-to-end on the device.",
         links=["docs/build-architecture.md", "docs/xt9-kernel-notes.md"]),

    dict(id="partial-rc", title="partial rc (capability advertisement) — workaround", cat="System",
         modes="all",
         status="tested",
         what="Tells the gnuton UI which capabilities exist, by appending tokens to nvram "
              "`rc_support` that stock XT9 does not advertise.",
         gnuton="gnuton's rc advertises more capabilities; the UI's menuTree.js hides pages "
                "when httpd's get_ui_support() reports no flag for them.",
         deps="`boot-hook`. Runtime-only nvram change (no commit).",
         franklin="A small shell stand-in for the rc behaviour we need: append `wifiradar`, "
                  "`nwtool`, `usbX`, `cake` to rc_support at boot, restore on stop. This is "
                  "the first slice of a partial-rc; further slices add data producers "
                  "(wireless station lists) as they are proven.",
         tested="Verified on the XT9: tokens are absent from stock's rc_support and the hook "
                "sets them at runtime; original string saved for rollback.",
         risks="Advertising a capability whose backend is missing would show a page that "
               "cannot work, so only tokens Franklin really provides are added.",
         evidence="workaround: stock rc_support lacks wifiradar/nfsd/nwtool/usbX/cake, which "
                  "is why gnuton-only menus are filtered out (menuTree.exclude).",
         links=["docs/build-architecture.md"]),

    dict(id="web-ui-overlay", title="Web UI overlay (gnuton httpd on :8088, optional /www bind) - workaround", cat="UI",
         modes="all",
         status="tested",
         what="Franklin's mechanism for presenting the gnuton UI on unmodified stock firmware: "
              "bind-mount gnuton's `httpd` and replace `/www`, with a parallel httpd on :8088 as "
              "the fallback.",
         gnuton="gnuton does not need this: its `httpd` and `/www` are simply part of the "
                "firmware image.",
         deps="the `web-ui` delta, `franklin-mount` (busybox mount refuses rootfs targets) and "
              "`overlayfs` (stock has no CONFIG_OVERLAY_FS); `acc_num` consistency.",
         franklin="Workaround that exists only because stock is not gnuton: overlay the gnuton "
                  "`/www` delta over the stock tree with overlayfs, bind a wrapper over "
                  "`/usr/sbin/httpd`, restart the stock httpd, and verify :80 before keeping the "
                  "swap. A :8088 instance of the merged tree remains available for testing, and "
                  "everything is a mount, so removal restores stock exactly.",
         tested="gnuton httpd + /www run on stock XT9 on :8088 with stock UI untouched; "
                "`acc_num=0` fix makes Advanced_System_Content load. Bind mode is opt-in via "
                "state/web-ui-overlay.bindwww and untested on the device yet.",
         risks="httpd/lib ABI coupling; a failed bind-mount can leave no UI — always keep the "
               "stock httpd running and the overlay reversible.",
         evidence="workaround: verified by running gnuton binaries on stock. Stock has no "
                  "equivalent mechanism; gnuton needs none.",
         links=["docs/firmware-comparison.md", "docs/xt9-kernel-notes.md"]),
]

REQUIRED = {"boot-hook"}

# Three-way separation of what a plan actually is:
#   gnuton-feature    upstream gnuton/Merlin provides it; Franklin ports it
#   workaround        Franklin-only mechanism replacing a gnuton capability stock lacks
#   franklin-feature  Franklin addition that gnuton does not have at all
#   stock             stock ASUSWRT already provides it (nothing to port)
#   proprietary       closed/licensed component that cannot be re-created
KINDS = ("gnuton-feature", "workaround", "franklin-feature", "entware-package", "stock",
         "proprietary")

KIND = {
    # workarounds: exist only because stock is not gnuton
    "boot-hook": "workaround",
    "kernel-modules": "workaround",
    "web-ui-overlay": "workaround",
    "franklin-mount": "workaround",
    "overlayfs": "workaround",
    "partial-rc": "workaround",
    "networkmap": "workaround",
    # Franklin additions (not gnuton)
    "entware": "franklin-feature",
    "download-manager": "entware-package",
    "disk-monitoring": "entware-package",
    # stock ASUSWRT already provides these
    "jffs": "stock",
    "samba-ftp-webdav": "stock",
    "aimesh": "stock",
    "guest-network": "stock",
    "nat-acceleration": "stock",
    "bridge-management": "stock",
    "igmp-snooping": "stock",
    "dhcp-leases": "stock",
    "disk-spindown": "stock",
    "cron": "stock",
    "ssh-access": "stock",
    "syslog": "stock",
    "ap-modes": "stock",
    "firmware-upgrade": "stock",
    "ipv6": "stock",
    "mac-filter": "stock",
    "parental-controls": "stock",
    "port-forwarding": "stock",
    "usb-modem": "stock",
    "wireless-tuning": "stock",
    "media-server": "stock",
    "time-machine": "stock",
    # closed/licensed
    "aiprotection": "proprietary",
    "cloud-sync": "proprietary",
    "traffic-analyzer": "proprietary",
}

UPSTREAM = {
    "boot-hook": "n/a — Franklin workaround (stock has no script hooks; Merlin uses /jffs/scripts)",
    "kernel-modules": "n/a — Franklin workaround (ASUS GPL 4.19.183, not gnuton)",
    "web-ui-overlay": "n/a — Franklin workaround (gnuton needs none: its httpd is in the image)",
    "networkmap": "gnuton networkmap daemon; Franklin needs a shm-size workaround",
    "franklin-mount": "n/a — Franklin workaround (ASUS busybox mount refuses rootfs targets)",
    "overlayfs": "n/a — Franklin workaround (CONFIG_OVERLAY_FS unset on stock)",
    "partial-rc": "n/a — Franklin workaround (stock rc advertises fewer capabilities than gnuton)",
    "amtm": "third-party (thelonelycoder/amtm) — bundled by gnuton/Merlin, not gnuton code",
    "cron": "stock ASUS (crond/cru); gnuton only adds the crontab command",
    "entware": "third-party (Entware project) - NOT gnuton",
    "cifs-client": "gnuton (ships fs/cifs/cifs.ko; stock kernel has no CIFS)",
    "download-manager": "n/a - Entware package (aria2); gnuton ships none",
    "disk-monitoring": "n/a - Entware package (smartmontools); neither stock nor gnuton",
    "aiprotection": "stock ASUS / Trend Micro (proprietary)",
    "cloud-sync": "stock ASUS (proprietary client)",
    "traffic-analyzer": "stock ASUS (proprietary DPI)",
    "jffs": "stock ASUS",
    "samba-ftp-webdav": "stock ASUS",
    "aimesh": "stock ASUS",
    "guest-network": "stock ASUS",
    "nat-acceleration": "stock ASUS (Broadcom CTF/FA)",
    "bridge-management": "stock ASUS (brctl)",
    "igmp-snooping": "stock ASUS / kernel driver",
    "dhcp-leases": "stock ASUS",
    "disk-spindown": "stock ASUS",
    "ssh-access": "stock ASUS (dropbear)",
    "syslog": "stock ASUS",
    "ap-modes": "stock ASUS",
    "firmware-upgrade": "stock ASUS (gnuton only changes the update channel)",
    "ipv6": "stock ASUS",
    "mac-filter": "stock ASUS",
    "parental-controls": "stock ASUS",
    "port-forwarding": "stock ASUS",
    "usb-modem": "stock ASUS",
    "wireless-tuning": "stock ASUS",
    "media-server": "stock ASUS (minidlna)",
    "time-machine": "stock ASUS",
}

# id -> list of feature ids it depends on (runtime and/or build)
DEPS = {
    "boot-hook": [],
    "jffs": [],
    # workarounds
    "kernel-modules": ["boot-hook"],
    "web-ui-overlay": ["web-ui", "boot-hook", "franklin-mount"],
    "networkmap": ["boot-hook", "franklin-mount"],
    "partial-rc": ["boot-hook"],
    # gnuton features
    "web-ui": ["boot-hook"],
    "cake-qos": ["kernel-modules", "boot-hook"],
    "tee": ["kernel-modules", "boot-hook"],
    "ipset": ["kernel-modules", "boot-hook"],
    "adaptive-qos": ["kernel-modules", "boot-hook", "ipset"],
    "qos-classification": ["adaptive-qos", "web-ui"],
    "traffic-monitor": ["web-ui"],
    "sysinfo": ["web-ui"],
    "wifi-insight": ["web-ui"],
    "wireless-survey": ["web-ui"],
    "network-tools": ["web-ui"],
    "temperature-monitoring": ["web-ui"],
    "snmp": ["boot-hook"],
    "tor": ["boot-hook", "firewall-custom"],
    "nfs": ["boot-hook", "kernel-modules"],
    "aidisk-nfs": ["nfs", "web-ui"],
    "amtm": ["boot-hook"],
    "cron": [],
    "franklin-mount": [],
    "overlayfs": ["kernel-modules"],
    "custom-scripts": ["boot-hook"],
    "nvram-tools": ["boot-hook"],
    "led-control": ["boot-hook"],
    "ddns": ["boot-hook"],
    "ntp": ["boot-hook"],
    "reboot-schedule": ["cron"],
    "dnsmasq-custom": ["boot-hook"],
    "dns-director": ["firewall-custom", "dnsmasq-custom", "boot-hook"],
    "dns-over-tls": ["dnsmasq-custom", "boot-hook"],
    "firewall-custom": ["boot-hook"],
    "vpn-director": ["firewall-custom", "boot-hook"],
    "vpn-killswitch": ["firewall-custom", "boot-hook"],
    "openvpn-client": ["boot-hook"],
    "openvpn-server": ["boot-hook", "firewall-custom"],
    "wireguard-client": ["boot-hook"],
    "wireguard-server": ["boot-hook", "firewall-custom"],
    "ipsec-vpn": ["boot-hook", "firewall-custom"],
    "vlan-iptv": ["boot-hook"],
    # franklin features
    "entware": ["boot-hook"],
    "cifs-client": ["boot-hook", "kernel-modules"],
    "download-manager": ["entware", "boot-hook"],
    "disk-monitoring": ["entware"],
    # stock
    "samba-ftp-webdav": [],
    "aimesh": [],
    "guest-network": [],
    "nat-acceleration": [],
    "bridge-management": ["boot-hook"],
    "igmp-snooping": [],
    "dhcp-leases": ["dnsmasq-custom"],
    "disk-spindown": [],
    "ssh-access": [],
    "syslog": ["boot-hook"],
    "ap-modes": [],
    "firmware-upgrade": [],
    "ipv6": [],
    "mac-filter": [],
    "parental-controls": ["firewall-custom"],
    "port-forwarding": ["firewall-custom"],
    "usb-modem": [],
    "wireless-tuning": [],
    "media-server": [],
    "time-machine": ["samba-ftp-webdav"],
    # proprietary
    "aiprotection": [],
    "cloud-sync": [],
    "traffic-analyzer": ["adaptive-qos"],
}

# Optional human-readable build/install note per feature (separable).
BUILD = {
    "jffs": "Nothing to build (stock). Enable JFFS if needed; Franklin only writes configs/logs there.",
    "boot-hook": "Copy usb/asusware.arm to the USB root; boot hook runs S* scripts.",
    "web-ui": "Deploy gnuton httpd + /www + differing libs to USB; start on :8088 (see docs/xt9-kernel-notes.md).",
    "franklin-mount": "Run features/franklin-mount/build.sh (static ARM binary via cross compiler).",
    "overlayfs": "Run features/overlayfs/build.sh -> builds exportfs.ko + overlay.ko from the ASUS GPL.",
    "kernel-modules": "Run features/kernel-modules/build.sh (calls tools/build-kernel-modules.sh with the ASUS GPL + device config).",
    "cake-qos": "Run features/cake-qos/build.sh -> builds sch_cake.ko from the ASUS GPL.",
    "tee": "Run features/tee/build.sh -> builds xt_TEE.ko + nf_dup_ipv4/6.ko.",
    "ipset": "Run features/ipset/build.sh -> builds ip_set*.ko; copy gnuton /usr/sbin/ipset.",
    "networkmap": "Run gnuton networkmap (creates shm 0x3e9 at 198168) or fix shm size.",
    "adaptive-qos": "Build BCM_DPI.ko (modularizable per audit) + bwdpi userspace/signatures.",
    "firewall-custom": "iptables/nat rules applied from the USB boot hook.",
    "dns-director": "iptables REDIRECT + dnsmasq config from boot hook.",
    "dns-over-tls": "Configure the stock `stubby` with a Franklin-managed config (no Entware).",
    "dnsmasq-custom": "Apply a dnsmasq config fragment from the boot hook (verify /jffs/configs).",
    "vpn-director": "ip rule/ip route rules from boot hook.",
    "vpn-killswitch": "prohibit ip rule from boot hook.",
    "entware": "Install Entware on USB (armv7sf-k3.2).",
    "cron": "Use stock `cru` from the boot hook; jobs are RAM-based, so re-add them at boot.",
    "disk-monitoring": "`opkg install smartmontools` (Entware), then schedule `smartctl` checks.",
    "download-manager": "`opkg install aria2` (Entware), then supervise it from the boot hook.",
    "custom-scripts": "Use USB asusware.arm (not /jffs/scripts on stock).",
}


TEMPLATE = """# {title}

**Category:** {cat}  
**Modes:** {modes}  
**Status:** `{status}`  
**Kind:** {kind}  
**Required:** {required}  
**Upstream:** {upstream}

## Dependencies

{dependencies}

## Build / install (separable)

{build}

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

## Why this kind (evidence)

{evidence}

## Links / sources

{links}
"""

def dep_links(fid):
    deps = DEPS.get(fid, [])
    if not deps:
        return "- none"
    return "\n".join("- [%s](%s.md)" % (d, d) for d in deps)


def kind_of(fid):
    return KIND.get(fid, "gnuton-feature")


def default_build(fid):
    k = kind_of(fid)
    if k == "stock":
        return "Nothing to build: stock firmware provides it. Franklin only must not break it."
    if k == "proprietary":
        return "Nothing to build: closed/licensed component. Stock keeps providing it."
    if k == "workaround":
        return "Franklin workaround: deploy from USB/boot hook (see Franklin approach)."
    if k == "franklin-feature":
        return "Franklin addition: install on USB and start from the boot hook."
    return "See Franklin approach above; deploy from USB/boot hook."


def topo_order():
    ids = [f["id"] for f in FEATURES]
    indeg = {i: 0 for i in ids}
    for i in ids:
        for d in DEPS.get(i, []):
            if d in indeg:
                indeg[i] += 1
    order = []
    ready = sorted([i for i in ids if indeg[i] == 0])
    while ready:
        n = ready.pop(0)
        order.append(n)
        for i in ids:
            if n in DEPS.get(i, []):
                indeg[i] -= 1
                if indeg[i] == 0:
                    ready.append(i)
        ready = sorted(set(ready))
    if len(order) != len(ids):
        order += [i for i in ids if i not in order]
    return order


KIND_TITLES = [
    ("workaround", "Workarounds (Franklin mechanisms, only because stock is not gnuton)",
     "These are **not gnuton features**. They exist so gnuton userland can run on unmodified "
     "stock firmware."),
    ("franklin-feature", "Franklin features (not in gnuton at all)",
     "Franklin additions. gnuton does not provide these; removing them changes nothing for "
     "any gnuton port."),
    ("entware-package", "Entware packages (third-party binaries Franklin integrates)",
     "The tool exists **only** in Entware: neither stock nor gnuton ships it. These depend on "
     "the `entware` provider, are not gnuton features, and break if Entware is removed."),
    ("gnuton-feature", "gnuton / Merlin features (ported by Franklin)",
     "Implemented upstream by gnuton/Asuswrt-Merlin; Franklin recreates or runs them."),
    ("stock", "Stock ASUSWRT features (nothing to port)",
     "Already in stock firmware. gnuton inherits them too; the plan exists so the parity "
     "table has a real link and so Franklin knows what not to break."),
    ("proprietary", "Proprietary / licensed (cannot be re-created)",
     "Closed components (Trend Micro DPI, ASUS cloud). Stock keeps them; Franklin must not "
     "disturb them."),
]


def index_table(fh, rows, ids):
    fh.write("| Feature | Category | Modes | Status | Required | Requires | Plan |\n")
    fh.write("|---|---|---|---|---|---|---|\n")
    for f in rows:
        if f["id"] not in ids:
            continue
        req = "**yes**" if f["id"] in REQUIRED else "no"
        deps = ", ".join("[%s](../features/%s.md)" % (d, d) for d in DEPS.get(f["id"], [])) or "—"
        fh.write("| %s | %s | %s | `%s` | %s | %s | [%s](%s.md) |\n" % (
            f["title"], f["cat"], f["modes"], f["status"], req, deps, f["id"], f["id"]))
    fh.write("\n")


def main():
    os.makedirs(OUT, exist_ok=True)
    rows = []
    ids = [f["id"] for f in FEATURES]
    dupes = sorted({i for i in ids if ids.count(i) > 1})
    if dupes:
        raise SystemExit("duplicate feature id(s): %s" % ", ".join(dupes))
    bad = [i for i in ids if kind_of(i) not in KINDS]
    if bad:
        raise SystemExit("invalid kind for: %s" % ", ".join(bad))
    unknown_deps = [(i, d) for i in ids for d in DEPS.get(i, []) if d not in ids]
    if unknown_deps:
        raise SystemExit("unknown dependency: %s" % ", ".join("%s->%s" % x for x in unknown_deps))
    for f in FEATURES:
        path = os.path.join(OUT, f["id"] + ".md")
        links = "\n".join("- `%s`" % l for l in f["links"]) or "- (none yet)"
        build = BUILD.get(f["id"], default_build(f["id"]))
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(TEMPLATE.format(
                links=links,
                required="yes" if f["id"] in REQUIRED else "no",
                kind=kind_of(f["id"]),
                upstream=UPSTREAM.get(f["id"], "gnuton / Asuswrt-Merlin"),
                evidence=f.get("evidence", "See the parity table and dependencies above."),
                dependencies=dep_links(f["id"]),
                build=build,
                **{k: f[k] for k in
                   ("title","cat","modes","status","what","gnuton","deps","franklin","tested","risks")}))
        rows.append(f)

    order = topo_order()

    # machine-readable manifest
    import json
    manifest = {
        "kinds": {k: [i for i in ids if kind_of(i) == k] for k in KINDS},
        "features": [
            dict(id=f["id"], title=f["title"], category=f["cat"],
                 modes=f["modes"], status=f["status"],
                 kind=kind_of(f["id"]),
                 required=(f["id"] in REQUIRED),
                 depends_on=DEPS.get(f["id"], []))
            for f in FEATURES
        ],
        "build_order": order,
    }
    with open(os.path.join(OUT, "manifest.json"), "w", encoding="utf-8", newline="\n") as fh:
        json.dump(manifest, fh, indent=2)

    # index
    idx = os.path.join(OUT, "README.md")
    with open(idx, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# Franklin feature plans\n\n")
        fh.write("One plan per feature in [`docs/gnuton-feature-parity.md`]"
                 "(../gnuton-feature-parity.md). Each plan states what the feature does,\n")
        fh.write("which modes it works in, what it needs, and what has been tested.\n\n")
        fh.write("## Kinds: three different things, kept apart\n\n")
        fh.write("| Kind | What it means |\n|---|---|\n")
        fh.write("| `workaround` | Franklin's own mechanism so gnuton userland runs on stock "
                 "(boot hook, kernel-module recipe, web UI overlay). **Not** gnuton features. |\n")
        fh.write("| `franklin-feature` | Franklin's own addition (the Entware provider itself). |\n")
        fh.write("| `entware-package` | Third-party tool that exists only in Entware (smartctl, "
                 "aria2, tcpdump). Not gnuton, not stock; depends on `entware`. |\n")
        fh.write("| `gnuton-feature` | Upstream gnuton/Merlin features Franklin ports. |\n")
        fh.write("| `stock` | Already in stock ASUSWRT; nothing to port, only \"don't break it\". |\n")
        fh.write("| `proprietary` | Closed/licensed (Trend Micro, ASUS cloud). |\n\n")
        fh.write("Every plan declares `Required` and `Dependencies` (as links), so a feature "
                 "can be removed without breaking others as long as nothing still depends on "
                 "it. Machine-readable: [`manifest.json`](manifest.json); planner: "
                 "`tools/franklin-build.py`.\n\n")
        fh.write("**Dependency direction:** JFFS is **not** a boot dependency. The boot hook "
                 "lives on USB (stock ignores `/jffs/scripts`); the boot hook is what\n")
        fh.write("applies/syncs config *into* `/jffs`, not the other way round.\n\n")
        fh.write("Status: `tested` = verified on the XT9; `stock` = stock-provided; "
                 "`planned`/`modular` = buildable; `research` = needs investigation; "
                 "`out-of-scope` = firmware/licensed only.\n\n")
        fh.write("## Index by kind\n\n")
        for kind, title, blurb in KIND_TITLES:
            sub = [i for i in ids if kind_of(i) == kind]
            fh.write("### %s (%d)\n\n%s\n\n" % (title, len(sub), blurb))
            index_table(fh, rows, set(sub))
        fh.write("## Build order (dependency-resolved)\n\n")
        fh.write("```\n")
        for i, fid in enumerate(order, 1):
            req = " [required]" if fid in REQUIRED else ""
            fh.write("%d. %s%s  (%s)\n" % (i, fid, req, kind_of(fid)))
        fh.write("```\n\n")
        fh.write("## Dependency graph\n\n")
        fh.write("Plain nodes/edges only: no `classDef`/`class` lines, which some Mermaid\n")
        fh.write("renderers choke on. Node colours are not needed — the sections above\n")
        fh.write("already group every plan by kind.\n\n")
        fh.write("```mermaid\ngraph TD\n")
        # Mermaid cannot parse hyphens in node ids, so use underscore aliases.
        alias = {i: i.replace("-", "_") for i in ids}
        for f in FEATURES:
            fh.write('  %s["%s"]\n' % (alias[f["id"]], f["id"]))
        for f in FEATURES:
            for d in DEPS.get(f["id"], []):
                fh.write("  %s --> %s\n" % (alias[d], alias[f["id"]]))
        fh.write("```\n")
    print("wrote %d feature files + README + manifest.json" % len(rows))


if __name__ == "__main__":
    main()
