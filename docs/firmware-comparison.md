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