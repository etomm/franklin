#!/bin/sh
# Traffic Monitor history: install the page, sample once, schedule the collector.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
src="$root/features/traffic-monitor"
data=/tmp/mnt/FRANKLIN/traffic-monitor

mkdir -p "$data"
[ -d /www ] || { echo "traffic-monitor: /www missing (web UI not mounted)"; exit 1; }

# Our page takes over the stock name the menu already points at.
cp -f "$src/page.asp" /www/Main_TrafficMonitor_last24.asp
echo "traffic-monitor: page installed (/Main_TrafficMonitor_last24.asp)"

# Collect once now (the first run only records counters, no deltas yet).
/bin/sh "$src/collect.sh" >/dev/null 2>&1
echo "traffic-monitor: first sample taken"

# Cron: RAM-based, so it is re-added at every boot.
cru d traffic_collect 2>/dev/null
cru a traffic_collect "*/5 * * * * $src/collect.sh" 2>/dev/null
echo "traffic-monitor: cron set (every 5 min)"
exit 0
