#!/bin/sh
# boot-hook: nothing to start. This hook exists so every feature is uniform:
# the asusware shim boots Franklin and this runs immediately after it.
# Resolve the Franklin root when run by hand; the boot driver exports it.
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

set -u
echo "boot-hook: usb=${USB:-?} root=${FRANKLIN_ROOT:-?}"
exit 0
