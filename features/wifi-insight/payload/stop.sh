#!/bin/sh
# Undo the runtime parts: page, capability token, cron. Keeps /jffs/addons and
# the history database.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

for j in collect scan trickle prune; do cru d "wifiinsight_$j" 2>/dev/null; done
echo "wifi-insight: cron removed"

rm -f /www/WiFi_Insight.asp /www/user1.asp 2>/dev/null
echo "wifi-insight: page removed"

# Drop the capability token again (rebuild the runtime string from partial-rc's
# managed view).
cur=" $(nvram get rc_support 2>/dev/null) "
new=$(printf '%s' "$cur" | sed 's/ wifiradar / /g; s/  */ /g; s/^ //; s/ $//')
[ "$new" != "$(nvram get rc_support)" ] && nvram set rc_support="$new" && echo "wifi-insight: wifiradar retired"

sed -i '/tabName: "WiFi Insight"/d' /www/require/modules/menuTree.js 2>/dev/null || true
exit 0
