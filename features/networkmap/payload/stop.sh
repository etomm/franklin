#!/bin/sh
# Stop gnuton's networkmap, restore stock's and restart it.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
helper="$root/opt/bin/franklin-mount"
pidfile="$root/state/networkmap.pid"

if [ -f "$pidfile" ]; then
    pid=$(cat "$pidfile" 2>/dev/null)
    [ -n "${pid:-}" ] && kill "$pid" 2>/dev/null && echo "networkmap: stopped gnuton daemon"
    rm -f "$pidfile"
fi
for p in $(ps | awk '/[n]etworkmap/ {print $1}'); do kill "$p" 2>/dev/null; done
sleep 1
ipcrm -M 0x000003e9 2>/dev/null

if grep -q ' /usr/sbin/networkmap ' /proc/mounts 2>/dev/null; then
    if [ -x "$helper" ]; then
        "$helper" umount /usr/sbin/networkmap
    else
        umount /usr/sbin/networkmap
    fi
    echo "networkmap: stock binary restored"
fi

# Start the stock daemon again from its original path.
nohup /usr/sbin/networkmap >/dev/null 2>&1 &
[ -x /sbin/service ] && /sbin/service restart_httpd >/dev/null 2>&1
exit 0
