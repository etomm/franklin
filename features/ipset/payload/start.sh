#!/bin/sh
# Load ip_set core + hash:ip, then make the gnuton `ipset` tool usable.
set -u
kver=$(uname -r)
dir="${FRANKLIN_ROOT:?}/kmod/$kver"
load() {
    mod="$1"
    grep -q "^$mod " /proc/modules && return 0
    [ -f "$dir/$mod.ko" ] || return 1
    insmod "$dir/$mod.ko"
}
load ip_set || { echo "ipset: ip_set failed"; exit 1; }
load ip_set_hash_ip || { echo "ipset: ip_set_hash_ip failed"; exit 1; }
[ -x "${FRANKLIN_ROOT}/bin/ipset" ] && ln -sf "${FRANKLIN_ROOT}/bin/ipset" /tmp/ipset 2>/dev/null
echo "ipset: loaded"
