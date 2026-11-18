#!/bin/sh
# Remove the runtime parts (page, menu entry, cron). Keeps /jffs/addons and the
# history database so a re-install does not lose data.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
page=user1.asp
title="WiFi Insight"
menutree=/www/require/modules/menuTree.js

for j in collect scan trickle prune; do cru d "wifiinsight_$j" 2>/dev/null; done
echo "wifi-insight: cron removed"

rm -f "/www/user/$page" "/www/user/user1.title" 2>/dev/null
echo "wifi-insight: page removed"

if grep -q "tabName: \"$title\"" "$menutree" 2>/dev/null; then
    sed -i "/tabName: \"$title\"/d" "$menutree"
    echo "wifi-insight: menu entry removed"
fi
exit 0
