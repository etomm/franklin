# Device profile: ASUS ZenWiFi XT9
# Sourced by S99franklin-boot. Override variables here.

FRANKLIN_DEVICE=xt9
FRANKLIN_SLEEP=8
FRANKLIN_APPLY_SWITCH=1

# Verified switch sequence (order matters). Expected: hw-switching=Enabled, softswitch=120.
franklin_apply_switch() {
  /bin/ethswctl -c hw-switching -o enable
  /bin/ethswctl -c softswitch -i eth0 -o enable
  /bin/ethswctl -c softswitch -i eth1 -o enable
}

# Entware arch for this device
FRANKLIN_ENTWARE_ARCH=armv7sf-k3.2
FRANKLIN_ENTWARE_URL=http://bin.entware.net/armv7sf-k3.2/installer/generic.sh

# Notes
# - Kernel 4.19.183, armv7l, 512MB DDR4, no 6GHz.
# - Stock firmware 3.0.0.4.388_24854 verified.
# - NVRAM script_* hooks do NOT run at boot on this firmware; asusware.arm does.
