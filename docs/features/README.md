# Franklin feature plans

One plan per feature in [`docs/gnuton-feature-parity.md`](../gnuton-feature-parity.md). Each plan states what the feature does,
which modes it works in, what it needs, and what has been tested.

## Kinds: three different things, kept apart

| Kind | What it means |
|---|---|
| `workaround` | Franklin's own mechanism so gnuton userland runs on stock (boot hook, kernel-module recipe, web UI overlay). **Not** gnuton features. |
| `franklin-feature` | Additions gnuton does not have at all (Entware, CIFS client, aria2, smartmontools). |
| `gnuton-feature` | Upstream gnuton/Merlin features Franklin ports. |
| `stock` | Already in stock ASUSWRT; nothing to port, only "don't break it". |
| `proprietary` | Closed/licensed (Trend Micro, ASUS cloud). |

Every plan declares `Required` and `Dependencies` (as links), so a feature can be removed without breaking others as long as nothing still depends on it. Machine-readable: [`manifest.json`](manifest.json); planner: `tools/franklin-build.py`.

**Dependency direction:** JFFS is **not** a boot dependency. The boot hook lives on USB (stock ignores `/jffs/scripts`); the boot hook is what
applies/syncs config *into* `/jffs`, not the other way round.

Status: `tested` = verified on the XT9; `stock` = stock-provided; `planned`/`modular` = buildable; `research` = needs investigation; `out-of-scope` = firmware/licensed only.

## Index by kind

### Workarounds (Franklin mechanisms, only because stock is not gnuton) (4)

These are **not gnuton features**. They exist so gnuton userland can run on unmodified stock firmware.

| Feature | Category | Modes | Status | Required | Requires | Plan |
|---|---|---|---|---|---|---|
| Network Map / client list | Monitoring | all | `tested` | no | [web-ui](../features/web-ui.md), [boot-hook](../features/boot-hook.md) | [networkmap](networkmap.md) |
| Boot hook (asusware.arm) | System | all | `tested` | **yes** | — | [boot-hook](boot-hook.md) |
| Kernel modules (build recipe) | Kernel | all | `tested` | no | [boot-hook](../features/boot-hook.md) | [kernel-modules](kernel-modules.md) |
| Web UI overlay (bind-mount httpd + /www) — workaround | UI | all | `tested` | no | [web-ui](../features/web-ui.md), [networkmap](../features/networkmap.md), [boot-hook](../features/boot-hook.md) | [web-ui-overlay](web-ui-overlay.md) |

### Franklin features (not in gnuton at all) (4)

Franklin additions. gnuton does not provide these; removing them changes nothing for any gnuton port.

| Feature | Category | Modes | Status | Required | Requires | Plan |
|---|---|---|---|---|---|---|
| Entware package ecosystem | Packages | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [entware](entware.md) |
| Disk monitoring (smartmontools) | Storage | all | `planned` | no | [entware](../features/entware.md) | [disk-monitoring](disk-monitoring.md) |
| CIFS mount (client) | Storage | all | `planned` | no | [boot-hook](../features/boot-hook.md), [kernel-modules](../features/kernel-modules.md) | [cifs-client](cifs-client.md) |
| Download manager (aria2) | Storage | all | `planned` | no | [entware](../features/entware.md), [boot-hook](../features/boot-hook.md) | [download-manager](download-manager.md) |

### gnuton / Merlin features (ported by Franklin) (36)

Implemented upstream by gnuton/Asuswrt-Merlin; Franklin recreates or runs them.

| Feature | Category | Modes | Status | Required | Requires | Plan |
|---|---|---|---|---|---|---|
| Web UI (gnuton httpd + /www) | UI | all (AP / Router / Mesh) | `tested` | no | [boot-hook](../features/boot-hook.md) | [web-ui](web-ui.md) |
| VPN Director | VPN | Router (needs WAN + routing) | `planned` | no | [firewall-custom](../features/firewall-custom.md), [boot-hook](../features/boot-hook.md) | [vpn-director](vpn-director.md) |
| VPN Killswitch | VPN | Router (WAN + VPN client) | `planned` | no | [firewall-custom](../features/firewall-custom.md), [boot-hook](../features/boot-hook.md) | [vpn-killswitch](vpn-killswitch.md) |
| OpenVPN Client | VPN | Router (WAN + VPN client) | `stock+` | no | [boot-hook](../features/boot-hook.md) | [openvpn-client](openvpn-client.md) |
| OpenVPN Server | VPN | Router | `stock+` | no | [boot-hook](../features/boot-hook.md), [firewall-custom](../features/firewall-custom.md) | [openvpn-server](openvpn-server.md) |
| WireGuard Client | VPN | Router | `stock+` | no | [boot-hook](../features/boot-hook.md) | [wireguard-client](wireguard-client.md) |
| WireGuard Server | VPN | Router | `stock+` | no | [boot-hook](../features/boot-hook.md), [firewall-custom](../features/firewall-custom.md) | [wireguard-server](wireguard-server.md) |
| IPSec VPN | VPN | Router | `stock+` | no | [boot-hook](../features/boot-hook.md), [firewall-custom](../features/firewall-custom.md) | [ipsec-vpn](ipsec-vpn.md) |
| DNS Director (DNSFilter) | DNS | Router (DHCP/DNS server) | `planned` | no | [firewall-custom](../features/firewall-custom.md), [dnsmasq-custom](../features/dnsmasq-custom.md), [boot-hook](../features/boot-hook.md) | [dns-director](dns-director.md) |
| DNS-over-TLS (DoT) | DNS | Router / AP | `planned` | no | [dnsmasq-custom](../features/dnsmasq-custom.md), [boot-hook](../features/boot-hook.md) | [dns-over-tls](dns-over-tls.md) |
| Custom dnsmasq config | DNS | Router / AP | `stock+` | no | [boot-hook](../features/boot-hook.md) | [dnsmasq-custom](dnsmasq-custom.md) |
| Custom firewall / NAT rules | Network | Router | `planned` | no | [boot-hook](../features/boot-hook.md) | [firewall-custom](firewall-custom.md) |
| Cake QoS | QoS | Router (WAN shaping) | `tested` | no | [kernel-modules](../features/kernel-modules.md), [boot-hook](../features/boot-hook.md) | [cake-qos](cake-qos.md) |
| Adaptive QoS / DPI | QoS | Router | `research` | no | [kernel-modules](../features/kernel-modules.md), [boot-hook](../features/boot-hook.md), [ipset](../features/ipset.md) | [adaptive-qos](adaptive-qos.md) |
| Traffic Monitor | Monitoring | Router (WAN stats); AP limited | `stock+` | no | [web-ui](../features/web-ui.md) | [traffic-monitor](traffic-monitor.md) |
| QoS Classification / Stats | QoS | Router | `research` | no | [adaptive-qos](../features/adaptive-qos.md), [web-ui](../features/web-ui.md) | [qos-classification](qos-classification.md) |
| Tools / Sysinfo | Monitoring | all | `stock+` | no | [web-ui](../features/web-ui.md) | [sysinfo](sysinfo.md) |
| WiFi Insight | Wireless | all (mesh/AP) | `stock+` | no | [web-ui](../features/web-ui.md) | [wifi-insight](wifi-insight.md) |
| Wireless Survey | Wireless | all | `stock+` | no | [web-ui](../features/web-ui.md) | [wireless-survey](wireless-survey.md) |
| Network Tools | Diagnostics | all | `stock+` | no | [web-ui](../features/web-ui.md) | [network-tools](network-tools.md) |
| SNMP | Services | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [snmp](snmp.md) |
| Tor | Services | Router | `planned` | no | [boot-hook](../features/boot-hook.md), [firewall-custom](../features/firewall-custom.md) | [tor](tor.md) |
| NFS server | Storage | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [nfs](nfs.md) |
| AiDisk NFS | Storage | all | `planned` | no | [nfs](../features/nfs.md), [web-ui](../features/web-ui.md) | [aidisk-nfs](aidisk-nfs.md) |
| amtm (terminal menu) | Tools | all | `planned` | no | [entware](../features/entware.md) | [amtm](amtm.md) |
| ipset | Network | all | `tested` | no | [kernel-modules](../features/kernel-modules.md), [boot-hook](../features/boot-hook.md) | [ipset](ipset.md) |
| TEE (packet duplication) | Network | all | `tested` | no | [kernel-modules](../features/kernel-modules.md), [boot-hook](../features/boot-hook.md) | [tee](tee.md) |
| cron / scheduled tasks | Automation | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [cron](cron.md) |
| Custom scripts | Automation | all | `tested` | no | [boot-hook](../features/boot-hook.md) | [custom-scripts](custom-scripts.md) |
| NVRAM tools / config export | System | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [nvram-tools](nvram-tools.md) |
| LED control | System | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [led-control](led-control.md) |
| Temperature monitoring | Monitoring | all | `stock+` | no | [web-ui](../features/web-ui.md) | [temperature-monitoring](temperature-monitoring.md) |
| DDNS (custom providers) | Network | Router | `planned` | no | [boot-hook](../features/boot-hook.md) | [ddns](ddns.md) |
| NTP client/server | System | all | `planned` | no | [boot-hook](../features/boot-hook.md) | [ntp](ntp.md) |
| Reboot schedule | Automation | all | `planned` | no | [cron](../features/cron.md) | [reboot-schedule](reboot-schedule.md) |
| VLAN / IPTV port tagging (ethswctl, softswitch) | Network | Router / AP (wired switch config) | `planned` | no | [boot-hook](../features/boot-hook.md) | [vlan-iptv](vlan-iptv.md) |

### Stock ASUSWRT features (nothing to port) (21)

Already in stock firmware. gnuton inherits them too; the plan exists so the parity table has a real link and so Franklin knows what not to break.

| Feature | Category | Modes | Status | Required | Requires | Plan |
|---|---|---|---|---|---|---|
| NAT acceleration (CTF/FA) | Network | Router | `out-of-scope` | no | — | [nat-acceleration](nat-acceleration.md) |
| Samba / FTP / WebDAV (stock USB apps) | Storage | all | `stock` | no | — | [samba-ftp-webdav](samba-ftp-webdav.md) |
| JFFS partition | Storage | all | `stock` | no | — | [jffs](jffs.md) |
| AiMesh | Wireless | Mesh (AiMesh router/node) | `stock` | no | — | [aimesh](aimesh.md) |
| Guest network | Wireless | Router / AP / Mesh | `stock` | no | — | [guest-network](guest-network.md) |
| Bridge management (brctl) | Network | all | `stock` | no | [boot-hook](../features/boot-hook.md) | [bridge-management](bridge-management.md) |
| IGMP snooping / multicast | Network | Router / AP | `out-of-scope` | no | — | [igmp-snooping](igmp-snooping.md) |
| DHCP static leases / custom config | DNS | Router (DHCP server) | `stock` | no | [dnsmasq-custom](../features/dnsmasq-custom.md) | [dhcp-leases](dhcp-leases.md) |
| Disk spindown / power management | Storage | all | `stock` | no | — | [disk-spindown](disk-spindown.md) |
| SSH access (dropbear / openssh) | System | all | `stock` | no | — | [ssh-access](ssh-access.md) |
| System log / remote syslog | Monitoring | all | `stock` | no | [boot-hook](../features/boot-hook.md) | [syslog](syslog.md) |
| AP / Bridge / Repeater / Media bridge modes | Wireless | AP / Router / Mesh | `stock` | no | — | [ap-modes](ap-modes.md) |
| Firmware upgrade helpers | System | all | `stock` | no | — | [firmware-upgrade](firmware-upgrade.md) |
| IPv6 (native, 6in4, 6to4, 6rd) | Network | Router | `stock` | no | — | [ipv6](ipv6.md) |
| MAC filter | Wireless | all | `stock` | no | — | [mac-filter](mac-filter.md) |
| Parental controls | Security | Router | `stock` | no | [firewall-custom](../features/firewall-custom.md) | [parental-controls](parental-controls.md) |
| Port forwarding / virtual server / DMZ | Network | Router | `stock` | no | [firewall-custom](../features/firewall-custom.md) | [port-forwarding](port-forwarding.md) |
| USB modem (3G/4G) | Network | Router | `stock` | no | — | [usb-modem](usb-modem.md) |
| Wireless tuning (band steering, Smart Connect, WPS) | Wireless | all (mesh/AP) | `stock` | no | — | [wireless-tuning](wireless-tuning.md) |
| Media server (minidlna) | Storage | all | `stock` | no | — | [media-server](media-server.md) |
| Time Machine (AFP) backup | Storage | all | `stock` | no | [samba-ftp-webdav](../features/samba-ftp-webdav.md) | [time-machine](time-machine.md) |

### Proprietary / licensed (cannot be re-created) (3)

Closed components (Trend Micro DPI, ASUS cloud). Stock keeps them; Franklin must not disturb them.

| Feature | Category | Modes | Status | Required | Requires | Plan |
|---|---|---|---|---|---|---|
| AiProtection (Trend Micro) | Security | Router | `out-of-scope` | no | — | [aiprotection](aiprotection.md) |
| Cloud sync (Dropbox, etc.) | Storage | all | `out-of-scope` | no | — | [cloud-sync](cloud-sync.md) |
| Traffic Analyzer / bandwidth monitor | Monitoring | Router | `out-of-scope` | no | [adaptive-qos](../features/adaptive-qos.md) | [traffic-analyzer](traffic-analyzer.md) |

## Build order (dependency-resolved)

```
1. aimesh  (stock)
2. aiprotection  (proprietary)
3. ap-modes  (stock)
4. boot-hook [required]  (workaround)
5. bridge-management  (stock)
6. cloud-sync  (proprietary)
7. cron  (gnuton-feature)
8. custom-scripts  (gnuton-feature)
9. ddns  (gnuton-feature)
10. disk-spindown  (stock)
11. dnsmasq-custom  (gnuton-feature)
12. dhcp-leases  (stock)
13. dns-over-tls  (gnuton-feature)
14. entware  (franklin-feature)
15. amtm  (gnuton-feature)
16. disk-monitoring  (franklin-feature)
17. download-manager  (franklin-feature)
18. firewall-custom  (gnuton-feature)
19. dns-director  (gnuton-feature)
20. firmware-upgrade  (stock)
21. guest-network  (stock)
22. igmp-snooping  (stock)
23. ipsec-vpn  (gnuton-feature)
24. ipv6  (stock)
25. jffs  (stock)
26. kernel-modules  (workaround)
27. cake-qos  (gnuton-feature)
28. cifs-client  (franklin-feature)
29. ipset  (gnuton-feature)
30. adaptive-qos  (gnuton-feature)
31. led-control  (gnuton-feature)
32. mac-filter  (stock)
33. media-server  (stock)
34. nat-acceleration  (stock)
35. nfs  (gnuton-feature)
36. ntp  (gnuton-feature)
37. nvram-tools  (gnuton-feature)
38. openvpn-client  (gnuton-feature)
39. openvpn-server  (gnuton-feature)
40. parental-controls  (stock)
41. port-forwarding  (stock)
42. reboot-schedule  (gnuton-feature)
43. samba-ftp-webdav  (stock)
44. snmp  (gnuton-feature)
45. ssh-access  (stock)
46. syslog  (stock)
47. tee  (gnuton-feature)
48. time-machine  (stock)
49. tor  (gnuton-feature)
50. traffic-analyzer  (proprietary)
51. usb-modem  (stock)
52. vlan-iptv  (gnuton-feature)
53. vpn-director  (gnuton-feature)
54. vpn-killswitch  (gnuton-feature)
55. web-ui  (gnuton-feature)
56. aidisk-nfs  (gnuton-feature)
57. network-tools  (gnuton-feature)
58. networkmap  (workaround)
59. qos-classification  (gnuton-feature)
60. sysinfo  (gnuton-feature)
61. temperature-monitoring  (gnuton-feature)
62. traffic-monitor  (gnuton-feature)
63. web-ui-overlay  (workaround)
64. wifi-insight  (gnuton-feature)
65. wireguard-client  (gnuton-feature)
66. wireguard-server  (gnuton-feature)
67. wireless-survey  (gnuton-feature)
68. wireless-tuning  (stock)
```

## Dependency graph

```mermaid
graph TD
  boot-hook --> web-ui
  firewall-custom --> vpn-director
  boot-hook --> vpn-director
  firewall-custom --> vpn-killswitch
  boot-hook --> vpn-killswitch
  boot-hook --> openvpn-client
  boot-hook --> openvpn-server
  firewall-custom --> openvpn-server
  boot-hook --> wireguard-client
  boot-hook --> wireguard-server
  firewall-custom --> wireguard-server
  boot-hook --> ipsec-vpn
  firewall-custom --> ipsec-vpn
  firewall-custom --> dns-director
  dnsmasq-custom --> dns-director
  boot-hook --> dns-director
  dnsmasq-custom --> dns-over-tls
  boot-hook --> dns-over-tls
  boot-hook --> dnsmasq-custom
  boot-hook --> firewall-custom
  kernel-modules --> cake-qos
  boot-hook --> cake-qos
  kernel-modules --> adaptive-qos
  boot-hook --> adaptive-qos
  ipset --> adaptive-qos
  web-ui --> traffic-monitor
  adaptive-qos --> qos-classification
  web-ui --> qos-classification
  web-ui --> sysinfo
  web-ui --> wifi-insight
  web-ui --> wireless-survey
  web-ui --> network-tools
  boot-hook --> snmp
  boot-hook --> tor
  firewall-custom --> tor
  boot-hook --> nfs
  nfs --> aidisk-nfs
  web-ui --> aidisk-nfs
  entware --> amtm
  boot-hook --> entware
  kernel-modules --> ipset
  boot-hook --> ipset
  kernel-modules --> tee
  boot-hook --> tee
  boot-hook --> cron
  boot-hook --> custom-scripts
  boot-hook --> nvram-tools
  boot-hook --> led-control
  entware --> disk-monitoring
  web-ui --> temperature-monitoring
  boot-hook --> ddns
  boot-hook --> ntp
  cron --> reboot-schedule
  web-ui --> networkmap
  boot-hook --> networkmap
  boot-hook --> kernel-modules
  boot-hook --> vlan-iptv
  boot-hook --> bridge-management
  boot-hook --> cifs-client
  kernel-modules --> cifs-client
  dnsmasq-custom --> dhcp-leases
  boot-hook --> syslog
  firewall-custom --> parental-controls
  firewall-custom --> port-forwarding
  adaptive-qos --> traffic-analyzer
  entware --> download-manager
  boot-hook --> download-manager
  samba-ftp-webdav --> time-machine
  web-ui --> web-ui-overlay
  networkmap --> web-ui-overlay
  boot-hook --> web-ui-overlay
  classDef gnuton_feature fill:#eef,stroke:#88a
  class web-ui,vpn-director,vpn-killswitch,openvpn-client,openvpn-server,wireguard-client,wireguard-server,ipsec-vpn,dns-director,dns-over-tls,dnsmasq-custom,firewall-custom,cake-qos,adaptive-qos,traffic-monitor,qos-classification,sysinfo,wifi-insight,wireless-survey,network-tools,snmp,tor,nfs,aidisk-nfs,amtm,ipset,tee,cron,custom-scripts,nvram-tools,led-control,temperature-monitoring,ddns,ntp,reboot-schedule,vlan-iptv gnuton_feature
  classDef workaround fill:#eef,stroke:#88a
  class networkmap,boot-hook,kernel-modules,web-ui-overlay workaround
  classDef franklin_feature fill:#eef,stroke:#88a
  class entware,disk-monitoring,cifs-client,download-manager franklin_feature
  classDef stock fill:#eef,stroke:#88a
  class nat-acceleration,samba-ftp-webdav,jffs,aimesh,guest-network,bridge-management,igmp-snooping,dhcp-leases,disk-spindown,ssh-access,syslog,ap-modes,firmware-upgrade,ipv6,mac-filter,parental-controls,port-forwarding,usb-modem,wireless-tuning,media-server,time-machine stock
  classDef proprietary fill:#eef,stroke:#88a
  class aiprotection,cloud-sync,traffic-analyzer proprietary
```
