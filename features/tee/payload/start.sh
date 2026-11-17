#!/bin/sh
# Load TEE and its nf_dup dependencies (IPv4 first, IPv6 optional).
set -u
kver=$(uname -r)
dir="${FRANKLIN_ROOT:?}/kmod/$kver"
load() {
    name="$1"
    mod=$(echo "$name" | tr '-' '_')
    grep -q "^$mod " /proc/modules && return 0
    [ -f "$dir/$name.ko" ] || return 0
    insmod "$dir/$name.ko" || return 1
}
load nf_dup_ipv4 || { echo "tee: nf_dup_ipv4 failed"; exit 1; }
load nf_dup_ipv6 || true
load xt_TEE || { echo "tee: xt_TEE failed"; exit 1; }
echo "tee: loaded"
