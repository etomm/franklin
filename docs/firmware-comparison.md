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

## gnuton firmware (downloaded, not yet extracted)
- gnuton 3004.388.11_1-gnuton1 for RT-AX95Q/XT8 was downloaded into
  `firmware/gnuton-xt8/RT-AX95Q_3004_388.11_1-gnuton1_puresqubi.w` (gitignored).
- Extraction of the squashfs rootfs failed with the available tooling: the
  id table could not be read (likely a non-standard squashfs layout). The
  image is available locally for extraction with appropriate tooling
  (e.g. `sasquatch` or a patched `unsquashfs`) to compare gnuton's changes
  against stock.