#!/bin/sh
# Bring the gnuton UI up on stock firmware.
#
#   parallel mode (default)  gnuton httpd on :8088, stock :80 untouched
#   replace mode             gnuton UI on :80:
#                              /www             <- overlayfs (gnuton tree over stock /www)
#                                                  or one bind mount as fallback
#                              /usr/sbin/httpd  <- wrapper that sets LD_LIBRARY_PATH
#
# Enable replace with:  touch franklin/state/web-ui-overlay.replace
#
# Two device facts drive this script:
#   * the rootfs is a read-only squashfs, so nothing can be overwritten, only
#     mounted over;
#   * ASUS's busybox `mount` refuses targets on that squashfs
#     ("Invalid mount path(/www)"), so mounts go through /opt/bin/franklin-mount,
#     which calls mount(2) directly.
set -u
root="${FRANKLIN_ROOT:?}"
httpd="$root/opt/bin/gnuton-httpd"
www="$root/opt/share/gnuton-www"
lib="$root/opt/lib/gnuton"
state="$root/state"
log="$root/log"
pidfile="$state/web-ui-overlay.pid"
wrapper="$state/httpd-wrapper.sh"
ovl="$state/overlay"
mnt="$ovl/www-mnt"
mount_helper="$root/opt/bin/franklin-mount"
mkdir -p "$state" "$log" "$ovl/upper" "$ovl/work" "$mnt"

[ -x "$httpd" ] || { echo "web-ui-overlay: missing $httpd"; exit 1; }
[ -d "$www" ] || { echo "web-ui-overlay: missing $www"; exit 1; }

# httpd/myUi reads acc_num while building the System page; a stale value
# segfaults the daemon (found on this device).
acc=$(nvram get acc_num 2>/dev/null)
if [ "${acc:-}" != "0" ]; then
    nvram set acc_num=0 2>/dev/null && nvram commit 2>/dev/null
    echo "web-ui-overlay: set acc_num=0 (was '${acc:-}')"
fi

http_ok() { wget -q -O /dev/null -T 5 "http://127.0.0.1:$1/" 2>/dev/null; }
is_mounted() { grep -q " $1 " /proc/mounts 2>/dev/null; }
restart_httpd() { [ -x /sbin/rc ] && /sbin/rc restart_httpd >/dev/null 2>&1; }

# mnt_host <src> <dst> | mnt_overlay <opts> <dst> | mnt_umount <dst>
mnt_host() {
    if [ -x "$mount_helper" ]; then
        "$mount_helper" "$1" "$2" "$3"
    else
        mount "--$1" "$2" "$3"
    fi
}
mnt_umount() {
    if [ -x "$mount_helper" ]; then
        "$mount_helper" umount "$1"
    else
        umount "$1"
    fi
}

# ---------------------------------------------------------------- replace mode
if [ -f "$state/web-ui-overlay.replace" ]; then
    echo "web-ui-overlay: replace mode"

    # 1. Pre-flight on a spare port: never touch the live UI with an unproven
    #    binary.
    if http_ok 8089; then
        echo "web-ui-overlay: port 8089 busy, cannot pre-flight"
        exit 1
    fi
    ( cd "$www" && LD_LIBRARY_PATH="$lib" "$httpd" -p 8089 ) >>"$log/preflight.log" 2>&1 &
    pre=$!
    sleep 2
    if ! http_ok 8089; then
        kill "$pre" 2>/dev/null
        echo "web-ui-overlay: pre-flight failed; stock UI untouched ($log/preflight.log)"
        exit 1
    fi
    kill "$pre" 2>/dev/null
    sleep 1
    echo "web-ui-overlay: pre-flight OK"

    # 2. Wrapper: rc restarts /usr/sbin/httpd by absolute path, so the
    #    replacement must be a script that sets the library path and execs the
    #    real binary.
    umask 022
    {
        echo '#!/bin/sh'
        echo "export LD_LIBRARY_PATH=\"$lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\""
        echo "cd \"$www\" || exit 1"
        echo "exec \"$httpd\" \"\$@\""
    } >"$wrapper"
    chmod 755 "$wrapper"

    # 3. /www: overlay (gnuton tree first, stock as the lower fallback) when the
    #    kernel supports it, otherwise one bind mount.
    if is_mounted /www; then
        echo "web-ui-overlay: /www already mounted"
    elif grep -qw overlay /proc/filesystems && \
         mount -t overlay overlay -o "lowerdir=$www:/www,upperdir=$ovl/upper,workdir=$ovl/work" "$mnt" 2>>"$log/overlay.log"; then
        echo "web-ui-overlay: overlay mounted (gnuton pages over stock)"
        if ! mnt_host bind "$mnt" /www; then
            echo "web-ui-overlay: cannot bind overlay over /www; rolling back"
            mnt_umount "$mnt"
            exit 1
        fi
    else
        echo "web-ui-overlay: overlay unavailable, falling back to a bind mount"
        mnt_host bind "$www" /www || { echo "web-ui-overlay: bind /www failed"; exit 1; }
    fi

    # 4. Binary swap, then let rc restart it.
    is_mounted /usr/sbin/httpd || mnt_host bind "$wrapper" /usr/sbin/httpd || {
        echo "web-ui-overlay: cannot mount over /usr/sbin/httpd"
        mnt_umount /www; mnt_umount "$mnt"; exit 1; }
    restart_httpd
    sleep 3

    # 5. Verify, roll back to stock if the UI did not come back.
    if http_ok 80; then
        echo "web-ui-overlay: :80 now serves the gnuton UI"
        exit 0
    fi
    echo "web-ui-overlay: :80 did not answer; rolling back to stock"
    mnt_umount /www
    is_mounted "$mnt" && mnt_umount "$mnt"
    is_mounted /usr/sbin/httpd && mnt_umount /usr/sbin/httpd
    restart_httpd
    exit 1
fi

# ------------------------------------------------------------- parallel mode
PORT="${FRANKLIN_WEBUI_PORT:-8088}"

if [ -f "$pidfile" ]; then
    old=$(cat "$pidfile" 2>/dev/null)
    if [ -n "${old:-}" ] && kill -0 "$old" 2>/dev/null; then
        echo "web-ui-overlay: already running on :$PORT (pid $old)"
        exit 0
    fi
    rm -f "$pidfile"
fi

cd "$www" || exit 1
LD_LIBRARY_PATH="$lib" nohup "$httpd" -p "$PORT" >>"$log/httpd-$PORT.log" 2>&1 &
pid=$!
echo "$pid" >"$pidfile"
sleep 1
if kill -0 "$pid" 2>/dev/null; then
    echo "web-ui-overlay: gnuton httpd on :$PORT (pid $pid)"
else
    rm -f "$pidfile"
    echo "web-ui-overlay: httpd exited; see $log/httpd-$PORT.log"
    exit 1
fi

# Optional: serve gnuton pages from the stock httpd as well (no restart).
if [ -f "$state/web-ui-overlay.bindwww" ]; then
    if is_mounted /www; then
        echo "web-ui-overlay: /www already mounted"
    else
        mnt_host bind "$www" /www && echo "web-ui-overlay: bind-mounted $www over /www"
    fi
fi
exit 0
