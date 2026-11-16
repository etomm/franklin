#!/bin/sh
# One-shot installer: lays the Franklin USB tree + /jffs profile onto a router.
# Run on the target router (or via SSH) as root.
set -eu

USB_ROOT="${1:-/mnt/sda1}"   # adjust to your USB mount
FRANKLIN_HOME=/jffs/franklin

echo "Installing Franklin to $USB_ROOT and $FRANKLIN_HOME"

# 1. asusware.arm tree
cp -a ./usb/asusware.arm "$USB_ROOT/"
# place boot hook
mkdir -p "$USB_ROOT/asusware.arm/etc/init.d"
cp ./core/boot/S99franklin-boot "$USB_ROOT/asusware.arm/etc/init.d/S99franklin-boot"
chmod +x "$USB_ROOT/asusware.arm/etc/init.d/S99franklin-boot"

# 2. /jffs profile + tools
mkdir -p "$FRANKLIN_HOME/device" "$FRANKLIN_HOME/core"
cp ./devices/xt9/profile.sh "$FRANKLIN_HOME/device/profile.sh"
cp ./core/tools/* "$FRANKLIN_HOME/core/" 2>/dev/null || true

# 3. tools
mkdir -p /opt/franklin
cp -a ./core /opt/franklin/ 2>/dev/null || true

echo "Done. Reboot to activate the asusware.arm hook."
echo "Verify: cat /tmp/franklin.log"
