#!/bin/sh
# Stop the spare httpd and undo the optional /www bind mount.
set -u
root="${FRANKLIN_ROOT:?}"
pidfile="$root/state/web-ui-overlay.pid"

if [ -f "$pidfile" ]; then
    pid=$(cat "$pidfile" 2>/dev/null)
    if [ -n "${pid:-}" ] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null
        sleep 1
        kill -9 "$pid" 2>/dev/null
        echo "web-ui-overlay: stopped pid $pid"
    fi
    rm -f "$pidfile"
fi

# Restore the stock /www if we were the ones who mounted over it.
if grep -q ' /www ' /proc/mounts 2>/dev/null; then
    umount /www 2>/dev/null && echo "web-ui-overlay: /www restored to stock"
fi
exit 0
