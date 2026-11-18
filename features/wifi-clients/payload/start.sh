#!/bin/sh
# Keep /www/franklin-wifi.js fresh (the page refreshes every 3 s).
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
state="$root/state"
log="$root/log"
pidfile="$state/wifi-clients.pid"
mkdir -p "$state" "$log"

[ -f /www/../www ] || true
grep -q ' /www ' /proc/mounts || { echo "wifi-clients: /www is not writable (web-ui-overlay off)"; exit 1; }

if [ -f "$pidfile" ]; then
    old=$(cat "$pidfile" 2>/dev/null)
    [ -n "${old:-}" ] && kill -0 "$old" 2>/dev/null && { echo "wifi-clients: already running (pid $old)"; exit 0; }
    rm -f "$pidfile"
fi

(
    while :; do
        /bin/sh "$root/features/wifi-clients/wifi-clients.sh" >>"$log/wifi-clients.log" 2>&1
        sleep 5
    done
) &
echo $! >"$pidfile"
sleep 2
if [ -s /www/franklin-wifi.js ]; then
    echo "wifi-clients: publishing /www/franklin-wifi.js ($(wc -c </www/franklin-wifi.js) bytes)"
else
    echo "wifi-clients: no data produced yet (see $log/wifi-clients.log)"
fi
exit 0
