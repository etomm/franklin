#!/bin/sh
# Stop the spare httpd, and undo any httpd//www replacement.
set -u
root="${FRANKLIN_ROOT:?}"
pidfile="$root/state/web-ui-overlay.pid"
wrapper="$root/state/httpd-wrapper.sh"

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

# Restore the stock binary and pages if we were the ones who mounted over them.
changed=0
if grep -q ' /www ' /proc/mounts 2>/dev/null; then
    umount /www 2>/dev/null && { echo "web-ui-overlay: /www restored to stock"; changed=1; }
fi
if grep -q ' /usr/sbin/httpd ' /proc/mounts 2>/dev/null; then
    umount /usr/sbin/httpd 2>/dev/null && { echo "web-ui-overlay: /usr/sbin/httpd restored to stock"; changed=1; }
fi
rm -f "$wrapper"

if [ "$changed" = "1" ] && [ -x /sbin/rc ]; then
    /sbin/rc restart_httpd >/dev/null 2>&1
    echo "web-ui-overlay: httpd restarted on the stock binary"
fi
exit 0
