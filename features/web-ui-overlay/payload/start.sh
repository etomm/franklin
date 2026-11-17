#!/bin/sh
# Bring the gnuton UI up on stock firmware.
#
#   parallel mode (default)  gnuton httpd on :8088, stock :80 untouched
#   replace mode             gnuton UI on :80
#
# Both modes serve the same overlay: only the gnuton *delta* is shipped, and
# the stock /www stays underneath as the fallback layer.
#
#   overlay(lowerdir=<delta>:/www, upperdir/workdir on USB)  -> /www (replace)
#                                                             or httpd cwd (parallel)
#
# Device facts that shape this script (all verified on the XT9):
#   * rootfs is a read-only squashfs: files can only be mounted over, not replaced;
#   * ASUS's busybox `mount` refuses targets on that squashfs
#     ("Invalid mount path(/www)"), so mounts go through /opt/bin/franklin-mount,
#     which calls mount(2) directly;
#   * overlayfs is not in stock, it comes from the `overlayfs` feature;
#   * httpd must run with cwd = the tree it serves, with the gnuton-only libs on
#     LD_LIBRARY_PATH, and acc_num=0 (otherwise Advanced_System_Content.asp
#     segfaults).
# Resolve the Franklin root when run by hand; the boot driver exports it.
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

set -u
root="${FRANKLIN_ROOT:?}"
httpd="$root/opt/bin/gnuton-httpd"
delta="$root/opt/share/gnuton-www"
lib="$root/opt/lib/gnuton"
state="$root/state"
log="$root/log"
pidfile="$state/web-ui-overlay.pid"
wrapper="$state/httpd-wrapper.sh"
ovl="$state/overlay"
mnt="$ovl/www-mnt"
upper="$ovl/upper"
work="$ovl/work"
helper="$root/opt/bin/franklin-mount"
mkdir -p "$state" "$log" "$upper" "$work" "$mnt"

[ -x "$httpd" ] || { echo "web-ui-overlay: missing $httpd"; exit 1; }
[ -d "$delta" ] || { echo "web-ui-overlay: missing $delta"; exit 1; }
if ! grep -qw overlay /proc/filesystems; then
    echo "web-ui-overlay: overlayfs not loaded (overlayfs feature disabled?)"
    exit 1
fi

# httpd/myUi reads acc_num while building the System page; a stale value
# segfaults the daemon.
acc=$(nvram get acc_num 2>/dev/null)
if [ "${acc:-}" != "0" ]; then
    nvram set acc_num=0 2>/dev/null && nvram commit 2>/dev/null
    echo "web-ui-overlay: set acc_num=0 (was '${acc:-}')"
fi

# HTTP probe. ASUS's /usr/sbin/wget is not a normal wget (-O silently writes
# nothing, no exit status), so use a raw request over nc and look at the status
# line. A gnuton-only static asset is the honest test: stock answers 404 for it, while .asp pages are auth-gated and redirect on both, so they prove nothing.
http_get() {  # http_get <port> <path> -> status line
    req="GET $2 HTTP/1.0"
    if command -v nc >/dev/null 2>&1; then
        printf '%s\r\n\r\n' "$req" | nc 127.0.0.1 "$1" 2>/dev/null | head -1
    else
        printf '%s\r\n\r\n' "$req" | busybox nc 127.0.0.1 "$1" 2>/dev/null | head -1
    fi
}
http_ok() {  # http_ok <port> [path]
    case "$(http_get "$1" "${2:-/}")" in
        *" 200 "*) return 0 ;;
    esac
    return 1
}
is_mounted() { grep -q " $1 " /proc/mounts 2>/dev/null; }
# /sbin/rc restart_httpd segfaults on stock XT9 (verified); /sbin/service works.
restart_httpd() {
    if [ -x /sbin/service ] && /sbin/service restart_httpd >/dev/null 2>&1; then
        return 0
    fi
    /sbin/rc restart_httpd >/dev/null 2>&1
}
mnt_host() {
    if [ -x "$helper" ]; then "$helper" "$1" "$2" "$3"; else mount "--$1" "$2" "$3"; fi
}
mnt_umount() {
    if [ -x "$helper" ]; then "$helper" umount "$1"; else umount "$1"; fi
}

# Whiteouts: stock pages gnuton dropped. Clear stale ones first so removing a
# name from the list takes effect, then recreate the current list.
find "$upper" -type c -exec rm -f {} + 2>/dev/null || true
if [ -f "$delta/WHITEOUTS" ]; then
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        mkdir -p "$upper/$(dirname "$name")"
        mknod "$upper/$name" c 0 0 2>/dev/null || true
    done <"$delta/WHITEOUTS"
fi

# Mount the overlay once, both modes use it.
if is_mounted "$mnt"; then
    echo "web-ui-overlay: overlay already mounted"
else
    mount -t overlay overlay \
        -o "lowerdir=$delta:/www,upperdir=$upper,workdir=$work" "$mnt" 2>>"$log/overlay.log" || {
        echo "web-ui-overlay: overlay mount failed (see $log/overlay.log)"
        exit 1
    }
    echo "web-ui-overlay: overlay mounted (gnuton delta over stock /www)"
fi

# ---------------------------------------------------------------- replace mode
if [ -f "$state/web-ui-overlay.replace" ]; then
    echo "web-ui-overlay: replace mode"

    # 1. Pre-flight on a spare port: never touch the live UI with an unproven
    #    binary.
    if http_ok 8089 /js/chart.min.js; then
        echo "web-ui-overlay: port 8089 busy, cannot pre-flight"
        exit 1
    fi
    ( cd "$mnt" && LD_LIBRARY_PATH="$lib" "$httpd" -p 8089 ) >>"$log/preflight.log" 2>&1 &
    pre=$!
    sleep 2
    if ! http_ok 8089 /js/chart.min.js; then
        kill "$pre" 2>/dev/null
        echo "web-ui-overlay: pre-flight failed; stock UI untouched ($log/preflight.log)"
        exit 1
    fi
    kill "$pre" 2>/dev/null
    sleep 1
    echo "web-ui-overlay: pre-flight OK"

    # Clear any earlier instance (parallel mode or a previous swap) so :80 is
    # free for the stock rc restart to bind with our wrapper.
    killall gnuton-httpd 2>/dev/null && sleep 1

    # 2. Wrapper: rc restarts /usr/sbin/httpd by absolute path, so the
    #    replacement must be a script that sets the library path and execs the
    #    real binary.
    umask 022
    {
        echo '#!/bin/sh'
        echo "export LD_LIBRARY_PATH=\"$lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\""
        echo "cd \"$mnt\" || exit 1"
        echo "exec \"$httpd\" \"\$@\""
    } >"$wrapper"
    chmod 755 "$wrapper"

    # 3. Serve the merged tree on :80 and swap the daemon.
    is_mounted /www || mnt_host bind "$mnt" /www || {
        echo "web-ui-overlay: cannot bind overlay over /www"; exit 1; }
    is_mounted /usr/sbin/httpd || mnt_host bind "$wrapper" /usr/sbin/httpd || {
        echo "web-ui-overlay: cannot mount over /usr/sbin/httpd"
        mnt_umount /www; exit 1; }
    restart_httpd
    sleep 3

    # 4. Verify, roll back to stock if the UI did not come back.
    if http_ok 80 /js/chart.min.js; then
        echo "web-ui-overlay: :80 now serves the gnuton UI"
        exit 0
    fi
    echo "web-ui-overlay: :80 did not answer; rolling back to stock"
    is_mounted /www && mnt_umount /www
    is_mounted /usr/sbin/httpd && mnt_umount /usr/sbin/httpd
    is_mounted "$mnt" && mnt_umount "$mnt"
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

cd "$mnt" || exit 1
LD_LIBRARY_PATH="$lib" nohup "$httpd" -p "$PORT" >>"$log/httpd-$PORT.log" 2>&1 &
pid=$!
echo "$pid" >"$pidfile"
sleep 1
if kill -0 "$pid" 2>/dev/null; then
    echo "web-ui-overlay: gnuton httpd on :$PORT (pid $pid), serving the merged tree"
else
    rm -f "$pidfile"
    echo "web-ui-overlay: httpd exited; see $log/httpd-$PORT.log"
    exit 1
fi

# Optional: serve the merged tree from the stock httpd as well (no restart).
if [ -f "$state/web-ui-overlay.bindwww" ]; then
    if is_mounted /www; then
        echo "web-ui-overlay: /www already mounted"
    else
        mnt_host bind "$mnt" /www && echo "web-ui-overlay: bind-mounted merged tree over /www"
    fi
fi
exit 0
