#!/bin/sh
# Stop the spare httpd and undo any /www or /usr/sbin/httpd replacement.
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

changed=0
umount_path /www && { echo "web-ui-overlay: /www restored to stock"; changed=1; }
umount_path /usr/sbin/httpd && { echo "web-ui-overlay: /usr/sbin/httpd restored to stock"; changed=1; }
umount_path "$mnt" && echo "web-ui-overlay: overlay detached"
rm -f "$wrapper"

if [ "$changed" = "1" ] && [ -x /sbin/rc ]; then
    /sbin/rc restart_httpd >/dev/null 2>&1
    echo "web-ui-overlay: httpd restarted on the stock binary"
fi
exit 0
