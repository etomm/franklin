#!/bin/sh
# Bring the gnuton UI up on stock firmware. Two modes:
#
#   (default) spare port :8088, stock :80 untouched
#   replace   bind-mount a wrapper over /usr/sbin/httpd + gnuton /www, then
#             restart the stock httpd, so :80 serves the gnuton UI
#
# Enable replace with:  touch franklin/state/web-ui-overlay.replace
#
# Verified on the XT9 (stock 3.0.0.4.388): gnuton httpd runs on stock, needs
# cwd=<www>, LD_LIBRARY_PATH=<gnuton libs>, and acc_num=0 (otherwise
# Advanced_System_Content.asp segfaults). Rootfs is a read-only squashfs, so
# replacing the binary can only be done with a bind mount.
set -u
root="${FRANKLIN_ROOT:?}"
httpd="$root/opt/bin/gnuton-httpd"
www="$root/opt/share/gnuton-www"
lib="$root/opt/lib/gnuton"
state="$root/state"
log="$root/log"
pidfile="$state/web-ui-overlay.pid"
wrapper="$state/httpd-wrapper.sh"
mkdir -p "$state" "$log"

[ -x "$httpd" ] || { echo "web-ui-overlay: missing $httpd"; exit 1; }
[ -d "$www" ] || { echo "web-ui-overlay: missing $www"; exit 1; }

# httpd/myUi reads acc_num while building the System page; a stale value
# segfaults the daemon (found on this device).
acc=$(nvram get acc_num 2>/dev/null)
if [ "${acc:-}" != "0" ]; then
    nvram set acc_num=0 2>/dev/null && nvram commit 2>/dev/null
    echo "web-ui-overlay: set acc_num=0 (was '${acc:-}')"
fi

http_ok() {  # http_ok <port>
    wget -q -O /dev/null -T 5 "http://127.0.0.1:$1/" 2>/dev/null && return 0
    return 1
}

is_mounted() { grep -q " $1 " /proc/mounts 2>/dev/null; }

restart_httpd() {
    if [ -x /sbin/rc ]; then
        /sbin/rc restart_httpd >/dev/null 2>&1
    fi
}

# ---------------------------------------------------------------- replace mode
if [ -f "$state/web-ui-overlay.replace" ]; then
    echo "web-ui-overlay: replace mode (bind-mount over /usr/sbin/httpd + /www)"

    # 1. Pre-flight on a spare port: never touch the stock UI with an unproven
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
        echo "web-ui-overlay: pre-flight failed; stock UI left untouched ($log/preflight.log)"
        exit 1
    fi
    kill "$pre" 2>/dev/null
    sleep 1
    echo "web-ui-overlay: pre-flight OK"

    # 2. Wrapper: rc restarts /usr/sbin/httpd on its own, so the replacement has
    #    to be a script that sets the library path and execs the real binary.
    umask 022
    {
        echo '#!/bin/sh'
        echo "export LD_LIBRARY_PATH=\"$lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\""
        echo "cd \"$www\" || exit 1"
        echo "exec \"$httpd\" \"\$@\""
    } >"$wrapper"
    chmod 755 "$wrapper"

    # 3. Swap the binary and the pages, then let rc restart it.
    is_mounted /usr/sbin/httpd || mount --bind "$wrapper" /usr/sbin/httpd || {
        echo "web-ui-overlay: cannot bind-mount /usr/sbin/httpd"; exit 1; }
    is_mounted /www || mount --bind "$www" /www || {
        echo "web-ui-overlay: cannot bind-mount /www"
        umount /usr/sbin/httpd 2>/dev/null; exit 1; }
    restart_httpd
    sleep 3

    # 4. Verify, and roll back to stock if the UI did not come back.
    if http_ok 80; then
        echo "web-ui-overlay: :80 now serves the gnuton UI"
        exit 0
    fi
    echo "web-ui-overlay: :80 did not answer; rolling back to stock"
    umount /www 2>/dev/null
    umount /usr/sbin/httpd 2>/dev/null
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
        echo "web-ui-overlay: /www already bind-mounted"
    else
        mount --bind "$www" /www && echo "web-ui-overlay: bind-mounted $www over /www"
    fi
fi
exit 0
