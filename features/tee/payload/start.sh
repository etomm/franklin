#!/bin/sh
# Load TEE and its nf_dup dependencies from this feature's own folder.
# Resolve the Franklin root when run by hand; the boot driver exports it.
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

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
