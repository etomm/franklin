#!/bin/sh
# Keep the MIT WiFi Insight add-on alive on stock firmware.
#
# On Merlin this add-on is restored by /jffs/scripts/services-start. Stock has no
# such hook, and two things it needs live in RAM only:
#   * /www/user/  -> /tmp/var/wwwext   (the page itself)
#   * cru         -> the cron schedule  (collector + neighbour scans)
# This hook rebuilds both from /jffs/addons/wifiinsight, and makes sure the menu
# entry exists (it lives on the overlay, so normally it survives a reboot).
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
src="$root/features/wifi-insight/files"
addon=/jffs/addons/wifiinsight
page=user1.asp
page_url=user1.asp   # page lives at the web root: it uses absolute /state.js, /js/...
title="WiFi Insight"
menutree=/www/require/modules/menuTree.js
www_user=/www/user

[ -d "$www_user" ] || { echo "wifi-insight: /www/user missing (web UI not mounted)"; exit 1; }

# 1. Make sure the add-on itself is on JFFS (it is the durable copy).
mkdir -p "$addon/cgi-bin"
for f in wifiinsight.sh wifiinsight.asp LICENSE; do
    [ -f "$src/$f" ] || continue
    if ! cmp -s "$src/$f" "$addon/$f" 2>/dev/null; then
        cp -f "$src/$f" "$addon/$f"
        echo "wifi-insight: installed $f"
    fi
done
chmod 755 "$addon/wifiinsight.sh"
echo "$page" >"$addon/webui_page"

# 2. Page + title. The page is served from the web root because it loads
#    absolute assets (/state.js, /js/jquery.js); the add-on's CGI output lives
#    in /www/user/wifiinsight, which the page addresses absolutely too.
cp -f "$addon/wifiinsight.asp" "/www/$page"
printf '%s' "$title" >"/www/user/${page%.asp}.title"
mkdir -p "/www/user/wifiinsight"
echo "wifi-insight: page restored (/$page)"

# 3. Menu entry (idempotent; only when the anchor is unique).
if ! grep -q "tabName: \"$title\"" "$menutree" 2>/dev/null; then
    if [ "$(grep -c 'url: "Advanced_WAdvanced_Content.asp"' "$menutree" 2>/dev/null)" = "1" ]; then
        sed -i "/tabName: \"$title\"/d" "$menutree"
        sed -i "/url: \"Advanced_WAdvanced_Content.asp\"/a {url: \"$page_url\", tabName: \"$title\"}," "$menutree"
        echo "wifi-insight: menu entry added ($page_url)"
    else
        echo "wifi-insight: menuTree anchor not found; page at /$page"
    fi
fi

# 4. Cron (RAM): same entries the add-on installs. SCAN_INTERVAL is in minutes.
for j in collect scan trickle prune; do cru d "wifiinsight_$j" 2>/dev/null; done
cru a wifiinsight_collect "* * * * * $addon/wifiinsight.sh collect" 2>/dev/null
scan_min=$(awk -F= '/^SCAN_INTERVAL=/ {print $2; exit}' "$addon/config" 2>/dev/null | awk '{print $1}')
case "$scan_min" in ''|*[!0-9]*) scan_min=30 ;; esac
if [ "$scan_min" -ge 1 ]; then
    cru a wifiinsight_scan "*/$scan_min * * * * $addon/wifiinsight.sh scan --delay" 2>/dev/null
fi
cru a wifiinsight_trickle "* * * * * $addon/wifiinsight.sh trickle" 2>/dev/null
cru a wifiinsight_prune "23 4 * * * $addon/wifiinsight.sh prune" 2>/dev/null
echo "wifi-insight: cron restored ($(cru l 2>/dev/null | grep -c wifiinsight) entries)"
exit 0
