#!/bin/sh
# Load ip_set core + hash:ip from this feature's folder, then expose the
# gnuton `ipset` tool if it was staged under the merged /opt prefix.
set -u
dir="${FRANKLIN_ROOT:?}/features/ipset"
load() {
    mod="$1"
    grep -q "^$mod " /proc/modules && return 0
    [ -f "$dir/$mod.ko" ] || return 1
    insmod "$dir/$mod.ko"
}
load ip_set || { echo "ipset: ip_set failed"; exit 1; }
load ip_set_hash_ip || { echo "ipset: ip_set_hash_ip failed"; exit 1; }
tool="$FRANKLIN_ROOT/opt/bin/ipset"
[ -x "$tool" ] && ln -sf "$tool" /tmp/ipset 2>/dev/null
echo "ipset: loaded"
