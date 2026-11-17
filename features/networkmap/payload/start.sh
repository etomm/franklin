#!/bin/sh
# Run gnuton's networkmap so the UI's shared-memory layout matches.
#
# Findings on the XT9:
#   * the gnuton UI reads shm key 0x3e9 and expects 198168 bytes; stock
#     allocates 197916, so the client list comes up empty;
#   * `service restart_networkmap` / `start_networkmap` are no-ops here, and no
#     watchdog respawns the daemon, so Franklin manages the process itself;
#   * gnuton's networkmap rewrites /jffs/nmp_cl_json.js with the real client
#     list, and gnuton httpd builds /tmp/nmp_cache.js from it.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
helper="$root/opt/bin/franklin-mount"
bin="$root/opt/sbin/gnuton-networkmap"
log="$root/log"
pidfile="$root/state/networkmap.pid"
client_json=/jffs/nmp_cl_json.js

[ -x "$bin" ] || { echo "networkmap: missing $bin"; exit 1; }
[ -x "$helper" ] || { echo "networkmap: missing $helper"; exit 1; }
mkdir -p "$root/state" "$log"

shm_bytes() { ipcs -m 2>/dev/null | awk '$1=="0x000003e9" {print $5; exit}'; }

# 1. Serve the gnuton binary at the path ASUS uses.
if ! grep -q ' /usr/sbin/networkmap ' /proc/mounts; then
    "$helper" bind "$bin" /usr/sbin/networkmap || {
        echo "networkmap: cannot bind gnuton binary"; exit 1; }
fi

# 2. Stop the stock daemon and drop its undersized segment.
for p in $(ps | awk '/[n]etworkmap/ {print $1}'); do
    kill "$p" 2>/dev/null && echo "networkmap: stopped stock daemon ($p)"
done
sleep 1
ipcrm -M 0x000003e9 2>/dev/null && echo "networkmap: removed old shm 0x3e9"

# 3. Start gnuton's daemon and wait for its layout.
before=$(ls -l "$client_json" 2>/dev/null | awk '{print $5}')
nohup /usr/sbin/networkmap >>"$log/networkmap.log" 2>&1 &
echo $! >"$pidfile"
i=0
while [ $i -lt 10 ]; do
    [ "$(shm_bytes)" = "198168" ] && break
    i=$((i+1)); sleep 1
done

size=$(shm_bytes)
if [ "$size" != "198168" ]; then
    echo "networkmap: shm is ${size:-none}, expected 198168"
    exit 1
fi
echo "networkmap: gnuton daemon up, shm 0x3e9 = 198168"

# 4. Give it a moment, then refresh httpd so its cache is rebuilt.
i=0
while [ $i -lt 5 ]; do
    now=$(ls -l "$client_json" 2>/dev/null | awk '{print $5}')
    [ -n "$now" ] && [ "$now" != "$before" ] && break
    i=$((i+1)); sleep 1
done
[ -s "$client_json" ] && echo "networkmap: client list written ($(wc -c <"$client_json") bytes)"
[ -x /sbin/service ] && /sbin/service restart_httpd >/dev/null 2>&1
exit 0
