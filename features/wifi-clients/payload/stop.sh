#!/bin/sh
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
pidfile="$FRANKLIN_ROOT/state/wifi-clients.pid"
if [ -f "$pidfile" ]; then
    pid=$(cat "$pidfile" 2>/dev/null)
    [ -n "${pid:-}" ] && kill "$pid" 2>/dev/null && echo "wifi-clients: stopped"
    rm -f "$pidfile"
fi
# Remove the generated file so the page falls back cleanly.
[ -f /www/franklin-wifi.js ] && rm -f /www/franklin-wifi.js
exit 0
