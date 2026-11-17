#!/bin/sh
# Start gnuton's rebuilt httpd with gnuton's /www on a separate port,
# leaving the stock httpd (port 80) untouched.
#
# Prereqs (on the USB stick, e.g. /tmp/mnt/FRANKEN):
#   gnuton-httpd            <- gnuton /usr/sbin/httpd
#   gnuton-www/www/         <- gnuton /www tree
#   gnuton-www/libovpn.so   <- gnuton /usr/lib/libovpn.so
#
# Usage: start-gnuton-webui.sh [port]
set -eu
PORT="${1:-8088}"
BASE="${BASE:-/tmp/mnt/FRANKEN}"
HTTPD="$BASE/gnuton-httpd"
WWW="$BASE/gnuton-www/www"
LIB="$BASE/gnuton-www"

[ -x "$HTTPD" ] || { echo "missing $HTTPD"; exit 1; }
[ -d "$WWW" ]   || { echo "missing $WWW"; exit 1; }
[ -f "$LIB/libovpn.so" ] || { echo "missing $LIB/libovpn.so"; exit 1; }

cd "$WWW"
LD_LIBRARY_PATH="$LIB" "$HTTPD" -p "$PORT" >/tmp/gnuton-httpd.log 2>&1 &
echo "gnuton httpd started on port $PORT (log: /tmp/gnuton-httpd.log)"
