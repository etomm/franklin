#!/bin/sh
# Restore the firmware's own x_Setting value, closing the read-only test access.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
saved="$root/state/x_Setting.orig"

if [ -f "$saved" ]; then
    orig=$(cat "$saved" 2>/dev/null)
    nvram set x_Setting="${orig:-1}" 2>/dev/null
    rm -f "$saved"
    echo "test-access: x_Setting restored to '${orig:-1}'"
else
    nvram set x_Setting=1 2>/dev/null
    echo "test-access: no saved value; x_Setting set to 1 (normal)"
fi
exit 0
