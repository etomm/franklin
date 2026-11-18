#!/bin/sh
# Stop the spare httpd and undo any /www or /usr/sbin/httpd replacement.
# Resolve the Franklin root when run by hand; the boot driver exports it.
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

set -u
root="${FRANKLIN_ROOT:?}"
pidfile="$root/state/web-ui-overlay.pid"
wrapper="$root/state/httpd-wrapper.sh"
mnt="$root/state/overlay/www-mnt"
helper="$root/opt/bin/franklin-mount"

umount_path() {
    path="$1"
    grep -q " $path " /proc/mounts 2>/dev/null || return 1
    if [ -x "$helper" ]; then
        "$helper" umount "$path" 2>/dev/null || umount "$path" 2>/dev/null
    else
        umount "$path" 2>/dev/null
    fi
}

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

# The daemon runs with its cwd inside the overlay mount, which makes the mount
# busy. Kill it first, otherwise the overlay stays mounted and start.sh reuses
# a stale view of the payload.
if killall gnuton-httpd 2>/dev/null; then
    echo "web-ui-overlay: stopped gnuton-httpd"
    sleep 1
fi

changed=0
umount_path /www && { echo "web-ui-overlay: /www restored to stock"; changed=1; }
umount_path /usr/sbin/httpd && { echo "web-ui-overlay: /usr/sbin/httpd restored to stock"; changed=1; }
umount_path "$mnt" && { echo "web-ui-overlay: overlay detached"; changed=1; }
rm -f "$wrapper"

# The daemon we started is called gnuton-httpd, so a plain `service
# restart_httpd` (which kills "httpd") would leave it holding :80 and the new
# stock httpd would fail to bind. Kill ours explicitly first.
if killall gnuton-httpd 2>/dev/null; then
    echo "web-ui-overlay: stopped gnuton-httpd"
    changed=1
    sleep 1
fi

if [ "$changed" = "1" ]; then
    if [ -x /sbin/service ]; then
        /sbin/service restart_httpd >/dev/null 2>&1
    else
        /sbin/rc restart_httpd >/dev/null 2>&1
    fi
    echo "web-ui-overlay: httpd restarted on the stock binary"
fi
exit 0
