#!/bin/sh
# Load sch_cake.ko (built from the ASUS GPL for this exact kernel).
set -u
. /etc/profile >/dev/null 2>&1 || true
kver=$(uname -r)
ko="${FRANKLIN_ROOT:?}/kmod/$kver/sch_cake.ko"
[ -f "$ko" ] || { echo "cake-qos: no module for kernel $kver"; exit 1; }
if grep -q '^sch_cake ' /proc/modules; then
    echo "cake-qos: already loaded"
    exit 0
fi
insmod "$ko" || exit 1
echo "cake-qos: loaded sch_cake"
