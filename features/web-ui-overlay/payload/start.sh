#!/bin/sh
# Start gnuton's httpd from USB on a spare port, leaving stock :80 alone.
#
# Verified behaviour on the XT9 (stock 3.0.0.4.388):
#   * httpd must run with cwd = the /www tree it serves,
#   * the gnuton-only libs must be reachable (LD_LIBRARY_PATH),
#   * acc_num must be 0 or Advanced_System_Content.asp segfaults,
#   * stock UI on :80 is unaffected.
set -u
PORT="${FRANKLIN_WEBUI_PORT:-8088}"
root="${FRANKLIN_ROOT:?}"
base="$root/features/web-ui"
www="$base/www"
lib="$base/lib"
httpd="$base/httpd"
state="$root/state"
log="$root/log"
pidfile="$state/web-ui-overlay.pid"
mkdir -p "$state" "$log"

[ -x "$httpd" ] || { echo "web-ui-overlay: missing $httpd"; exit 1; }
[ -d "$www" ] || { echo "web-ui-overlay: missing $www"; exit 1; }

# Already running?
if [ -f "$pidfile" ]; then
    old=$(cat "$pidfile" 2>/dev/null)
    if [ -n "${old:-}" ] && kill -0 "$old" 2>/dev/null; then
        echo "web-ui-overlay: already running on :$PORT (pid $old)"
        exit 0
    fi
    rm -f "$pidfile"
fi

# httpd/myUi reads acc_num while building the System page; a stale value
# segfaults the daemon (found on this device).
acc=$(nvram get acc_num 2>/dev/null)
if [ "${acc:-}" != "0" ]; then
    nvram set acc_num=0 2>/dev/null && nvram commit 2>/dev/null
    echo "web-ui-overlay: set acc_num=0 (was '${acc:-}')"
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

# Optional: serve gnuton pages from the stock httpd as well.
if [ -f "$state/web-ui-overlay.bindwww" ]; then
    if mountpoint -q /www 2>/dev/null || grep -q ' /www ' /proc/mounts; then
        echo "web-ui-overlay: /www already bind-mounted"
    else
        mount --bind "$www" /www && echo "web-ui-overlay: bind-mounted $www over /www"
    fi
fi
exit 0
