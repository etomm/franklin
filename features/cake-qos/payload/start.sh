#!/bin/sh
# Load sch_cake.ko from this feature's own folder.
# Resolve the Franklin root when run by hand; the boot driver exports it.
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

set -u
dir="${FRANKLIN_ROOT:?}/features/cake-qos"
ko="$dir/sch_cake.ko"
[ -f "$ko" ] || { echo "cake-qos: no module (run features/cake-qos/build.sh)"; exit 1; }
if grep -q '^sch_cake ' /proc/modules; then
    echo "cake-qos: already loaded"
    exit 0
fi
insmod "$ko" || exit 1
echo "cake-qos: loaded sch_cake"
