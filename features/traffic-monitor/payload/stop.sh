#!/bin/sh
# Remove the pages and the schedule; keep the history database on the USB.
set -u
cru d traffic_collect 2>/dev/null
echo "traffic-monitor: cron removed"
rm -f /www/Main_TrafficMonitor_last24.asp \
      /www/Main_TrafficMonitor_daily.asp \
      /www/Main_TrafficMonitor_monthly.asp \
      /www/traffic-data.asp 2>/dev/null
echo "traffic-monitor: pages removed"
exit 0
