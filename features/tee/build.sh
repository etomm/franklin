#!/bin/sh
# Build xt_TEE.ko + nf_dup_ipv4/6.ko for the XT9 (kernel 4.19.183).
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
: "${GPL:?set GPL to the ASUS GPL zip}"
: "${CONFIG:?set CONFIG to the device kernel config}"
exec sh "$ROOT/tools/build-kernel-modules.sh" \
  --gpl "$GPL" --config "$CONFIG" \
  --enable "NETFILTER_XT_TARGET_TEE=m NF_DUP_IPV4=m NF_DUP_IPV6=m" \
  --modules "net/netfilter/xt_TEE.ko net/ipv4/netfilter/nf_dup_ipv4.ko net/ipv6/netfilter/nf_dup_ipv6.ko" \
  --out "$ROOT/features/tee/payload" "$@"
