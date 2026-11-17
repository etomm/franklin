# Franklin feature plans

One plan per gnuton/Merlin feature. Each plan explains what the feature
does, how gnuton implements it, which modes it works in, what Franklin
needs to recreate it, and what has been tested/verified.

Status: `tested` = verified on the XT9; `stock` = handled by stock
firmware; `modular`/`planned` = buildable/planned; `research` =
needs investigation; `out-of-scope` = firmware-level only.

| Feature | Category | Modes | Status | Plan |
|---|---|---|---|---|
| Web UI (gnuton httpd + /www) | UI | all (AP / Router / Mesh) | `tested` | [web-ui](web-ui.md) |
| VPN Director | VPN | Router (needs WAN + routing) | `planned` | [vpn-director](vpn-director.md) |
| VPN Killswitch | VPN | Router (WAN + VPN client) | `planned` | [vpn-killswitch](vpn-killswitch.md) |
| OpenVPN Client | VPN | Router (WAN + VPN client) | `stock+` | [openvpn-client](openvpn-client.md) |
| OpenVPN Server | VPN | Router | `stock+` | [openvpn-server](openvpn-server.md) |
| WireGuard Client | VPN | Router | `stock+` | [wireguard-client](wireguard-client.md) |
| WireGuard Server | VPN | Router | `stock+` | [wireguard-server](wireguard-server.md) |
| IPSec VPN | VPN | Router | `stock+` | [ipsec-vpn](ipsec-vpn.md) |
| DNS Director (DNSFilter) | DNS | Router (DHCP/DNS server) | `planned` | [dns-director](dns-director.md) |
| DNS-over-TLS (DoT) | DNS | Router / AP | `planned` | [dns-over-tls](dns-over-tls.md) |
| Custom dnsmasq config | DNS | Router / AP | `stock+` | [dnsmasq-custom](dnsmasq-custom.md) |
| Custom firewall / NAT rules | Network | Router | `planned` | [firewall-custom](firewall-custom.md) |
| NAT acceleration (CTF/FA) | Network | Router | `out-of-scope` | [nat-acceleration](nat-acceleration.md) |
| Cake QoS | QoS | Router (WAN shaping) | `tested` | [cake-qos](cake-qos.md) |
| Adaptive QoS / DPI | QoS | Router | `research` | [adaptive-qos](adaptive-qos.md) |
| Traffic Monitor | Monitoring | Router (WAN stats); AP limited | `stock+` | [traffic-monitor](traffic-monitor.md) |
| QoS Classification / Stats | QoS | Router | `research` | [qos-classification](qos-classification.md) |
| Tools / Sysinfo | Monitoring | all | `stock+` | [sysinfo](sysinfo.md) |
| WiFi Insight | Wireless | all (mesh/AP) | `stock+` | [wifi-insight](wifi-insight.md) |
| Wireless Survey | Wireless | all | `stock+` | [wireless-survey](wireless-survey.md) |
| Network Tools | Diagnostics | all | `stock+` | [network-tools](network-tools.md) |
| SNMP | Services | all | `planned` | [snmp](snmp.md) |
| Tor | Services | Router | `planned` | [tor](tor.md) |
| NFS server | Storage | all | `planned` | [nfs](nfs.md) |
| Samba / FTP / WebDAV (stock USB apps) | Storage | all | `stock` | [samba-ftp-webdav](samba-ftp-webdav.md) |
| AiDisk NFS | Storage | all | `planned` | [aidisk-nfs](aidisk-nfs.md) |
| amtm (terminal menu) | Tools | all | `planned` | [amtm](amtm.md) |
| Entware package ecosystem | Packages | all | `planned` | [entware](entware.md) |
| ipset | Network | all | `tested` | [ipset](ipset.md) |
| TEE (packet duplication) | Network | all | `tested` | [tee](tee.md) |
| cron / scheduled tasks | Automation | all | `planned` | [cron](cron.md) |
| Custom scripts | Automation | all | `tested` | [custom-scripts](custom-scripts.md) |
| JFFS partition | Storage | all | `stock` | [jffs](jffs.md) |
| NVRAM tools / config export | System | all | `planned` | [nvram-tools](nvram-tools.md) |
| LED control | System | all | `planned` | [led-control](led-control.md) |
| Disk monitoring (smartmontools) | Storage | all | `planned` | [disk-monitoring](disk-monitoring.md) |
| Temperature monitoring | Monitoring | all | `stock+` | [temperature-monitoring](temperature-monitoring.md) |
| DDNS (custom providers) | Network | Router | `planned` | [ddns](ddns.md) |
| NTP client/server | System | all | `planned` | [ntp](ntp.md) |
| Reboot schedule | Automation | all | `planned` | [reboot-schedule](reboot-schedule.md) |
| AiMesh | Wireless | Mesh (AiMesh router/node) | `stock` | [aimesh](aimesh.md) |
| Guest network | Wireless | Router / AP / Mesh | `stock` | [guest-network](guest-network.md) |
| Network Map / client list | Monitoring | all | `tested` | [networkmap](networkmap.md) |
| Boot hook (asusware.arm) | System | all | `tested` | [boot-hook](boot-hook.md) |
| Kernel modules (build recipe) | Kernel | all | `tested` | [kernel-modules](kernel-modules.md) |
