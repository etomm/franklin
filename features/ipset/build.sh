#!/bin/sh
# Build ip_set.ko + ip_set_hash_ip.ko for the XT9 (kernel 4.19.183).
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
: "${GPL:?set GPL to the ASUS GPL zip}"
: "${CONFIG:?set CONFIG to the device kernel config}"
exec sh "$ROOT/tools/build-kernel-modules.sh" \
  --gpl "$GPL" --config "$CONFIG" \
  --enable "IP_SET=m IP_SET_HASH_IP=m IP_SET_HASH_NET=m" \
  --modules "net/netfilter/ipset/ip_set.ko net/netfilter/ipset/ip_set_hash_ip.ko" \
  --out "$ROOT/build/ipset" "$@"
