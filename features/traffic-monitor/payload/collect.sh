#!/bin/sh
# Sample interface counters into sqlite, then publish the 24h series for the
# page. Runs from cron (every 5 minutes) and once at boot.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
data="${TRAFFIC_DATA_DIR:-/tmp/mnt/FRANKLIN/traffic-monitor}"
db="$data/traffic.db"
statef="$data/last-counters"
out=/www/traffic-data.asp
IFACES="${TRAFFIC_IFACES:-br0 eth0 eth4 eth5 eth6}"
SQLITE=/usr/sbin/sqlite3
now=$(date +%s)

mkdir -p "$data"
"$SQLITE" "$db" <<'SQL' >/dev/null 2>&1
CREATE TABLE IF NOT EXISTS samples(
    ts INTEGER NOT NULL,
    ifname TEXT NOT NULL,
    rx INTEGER NOT NULL,
    tx INTEGER NOT NULL,
    secs INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_samples_ts ON samples(ts);
SQL

# Read current counters, store deltas against the previous run.
newstate="$statef.new"
: >"$newstate"
for ifc in $IFACES; do
    line=$(grep -E "^ *$ifc:" /proc/net/dev 2>/dev/null | head -1)
    [ -n "$line" ] || continue
    set -- $(printf '%s' "$line" | cut -d: -f2)
    rx=$1; tx=$9
    prev=$(grep "^$ifc " "$statef" 2>/dev/null | head -1)
    if [ -n "$prev" ]; then
        set -- $prev
        prx=$2; ptx=$3; pts=$4
        drx=$((rx - prx)); dtx=$((tx - ptx)); secs=$((now - pts))
        [ "$secs" -gt 0 ] || secs=1
        [ "$drx" -ge 0 ] && [ "$dtx" -ge 0 ] || { drx=0; dtx=0; }
        "$SQLITE" "$db" "INSERT INTO samples(ts,ifname,rx,tx,secs) VALUES($now,'$ifc',$drx,$dtx,$secs);" >/dev/null 2>&1
    fi
    echo "$ifc $rx $tx $now" >>"$newstate"
done
mv -f "$newstate" "$statef"

# Keep 31 days.
"$SQLITE" "$db" "DELETE FROM samples WHERE ts < $((now - 31*86400));" >/dev/null 2>&1

# Publish the last 24 h as a JS include: one array of [tsSec, inBps, outBps]
# per interface, already reduced to 5-minute buckets by the collector cadence.
{
    echo "var TM = { generated: $now, ifaces: {"
    first=1
    for ifc in $IFACES; do
        rows=$("$SQLITE" -separator ' ' "$db" \
            "SELECT ts, CAST(rx*8/secs AS INTEGER), CAST(tx*8/secs AS INTEGER)
               FROM samples WHERE ifname='$ifc' AND ts >= $((now - 86400)) ORDER BY ts;" 2>/dev/null)
        [ -n "$rows" ] || continue
        [ "$first" = "1" ] || printf ',\n'
        first=0
        printf '"%s": [' "$ifc"
        printf '%s\n' "$rows" | awk '
            { printf "%s[%s,%s,%s]", (NR>1?",":""), $1, $2, $3 }
        '
        printf ']'
    done
    echo
    echo "}};"
} >"$out.tmp" 2>/dev/null
[ -s "$out.tmp" ] && mv "$out.tmp" "$out"
echo "traffic-monitor: sampled, series $(wc -c <"$out" 2>/dev/null) bytes"
