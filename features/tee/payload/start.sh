#!/bin/sh
# Load TEE and its nf_dup dependencies from this feature's own folder.
set -u
dir="${FRANKLIN_ROOT:?}/features/tee"
load() {
    name="$1"
    mod=$(echo "$name" | tr '-' '_')
    grep -q "^$mod " /proc/modules && return 0
    [ -f "$dir/$name.ko" ] || return 1
    insmod "$dir/$name.ko"
}
load nf_dup_ipv4 || { echo "tee: nf_dup_ipv4 failed"; exit 1; }
load nf_dup_ipv6 || true
load xt_TEE || { echo "tee: xt_TEE failed"; exit 1; }
echo "tee: loaded"
