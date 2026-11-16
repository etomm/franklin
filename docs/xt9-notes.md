# XT9 notes

## Verified (stock firmware 3.0.0.4.388_24854, AP mode)
- Kernel 4.19.183, armv7l, read-only squashfs root, persistent /jffs.
- asusware.arm app-folder hook runs at boot (verified log: "S99xt9-log start").
- NVRAM script_boot/script_usbmount/etc. do NOT run at boot on this firmware.
- ethswctl switch sequence (order matters):
  1. ethswctl -c hw-switching -o enable
  2. ethswctl -c softswitch -i eth0 -o enable
  3. ethswctl -c softswitch -i eth1 -o enable
  Expected: hw-switching=Enabled, softswitch=120 (0x78).
- /www read-only but overlayable via bind mount; no apply.cgi file (backend in httpd).

## Not possible safely
- Arbitrary VLAN-tagged Wi-Fi SSIDs (stock firmware limitation).
- Kernel/board/radio/switch module porting from other models.

## Recovery
- Keep SSH key in ASUS settings (survives reboot).
- Keep a known-good USB stick; /jffs for critical scripts.
- Console/reset path available.
