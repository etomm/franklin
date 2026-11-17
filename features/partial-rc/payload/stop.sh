#!/bin/sh
# Restore the firmware's own rc_support string.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
orig="$FRANKLIN_ROOT/state/rc_support.orig"
if [ -f "$orig" ]; then
    nvram set rc_support="$(cat "$orig")" 2>/dev/null
    echo "partial-rc: restored original rc_support"
else
    echo "partial-rc: no saved original; reboot regenerates it"
fi
exit 0
