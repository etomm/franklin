#!/bin/sh
# Build the XT9 kernel extras (Cake, TEE, nf_dup, ipset).
# Requires: GPL (ASUS GPL zip), CONFIG (device config).
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
: "${GPL:?set GPL to the ASUS GPL zip}"
: "${CONFIG:?set CONFIG to the device kernel config}"
exec sh "$ROOT/tools/build-kernel-modules.sh" \
  --gpl "$GPL" --config "$CONFIG" \
  --enable "NET_SCH_CAKE=m NETFILTER_XT_TARGET_TEE=m NF_DUP_IPV4=m NF_DUP_IPV6=m IP_SET=m IP_SET_HASH_IP=m IP_SET_HASH_NET=m" \
  --modules "net/sched/sch_cake.ko net/netfilter/xt_TEE.ko net/ipv4/netfilter/nf_dup_ipv4.ko net/ipv6/netfilter/nf_dup_ipv6.ko net/netfilter/ipset/ip_set.ko net/netfilter/ipset/ip_set_hash_ip.ko" \
  --out "$ROOT/build/kernel-modules" "$@"
