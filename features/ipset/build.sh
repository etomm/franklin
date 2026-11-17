#!/bin/sh
# Build ip_set.ko + ip_set_hash_ip.ko for the XT9 (kernel 4.19.183) and stage
# the gnuton `ipset` tool into the merged /opt prefix.
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
: "${GPL:?set GPL to the ASUS GPL zip}"
: "${CONFIG:?set CONFIG to the device kernel config}"
sh "$ROOT/tools/build-kernel-modules.sh" \
  --gpl "$GPL" --config "$CONFIG" \
  --enable "IP_SET=m IP_SET_HASH_IP=m IP_SET_HASH_NET=m" \
  --modules "net/netfilter/ipset/ip_set.ko net/netfilter/ipset/ip_set_hash_ip.ko" \
  --out "$ROOT/features/ipset/payload" "$@"

# Optional userspace tool: taken from the extracted gnuton rootfs, not shipped.
GNUTON_ROOTFS="${GNUTON_ROOTFS:-$ROOT/firmware/gnuton-xt8/rootfs}"
if [ -x "$GNUTON_ROOTFS/usr/sbin/ipset" ]; then
    mkdir -p "$ROOT/features/ipset/payload/opt/bin"
    cp "$GNUTON_ROOTFS/usr/sbin/ipset" "$ROOT/features/ipset/payload/opt/bin/ipset"
    chmod 755 "$ROOT/features/ipset/payload/opt/bin/ipset"
    echo "staged opt/bin/ipset"
fi
