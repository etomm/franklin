#!/bin/sh
# Produce /www/franklin-wifi.js: the dataarray*/wificlients* variables that the
# gnuton wireless-log page expects from <% get_wl_status(); %>.
#
# The handler in gnuton's httpd cannot be used here: that binary is an XT8 build
# and parses the XT9 driver's sta_info with the wrong layout, which drops the
# opening quote of the flags field and kills the page's JS.
#
# Data source: the vendor `wl` tool (same driver, correct structs for this
# model). Fields the page reads:
#   wificlients[N] = [mac, ip, name, vendor, rssi, rx, tx, time, nss, phy, bw, flags]
#   dataarray[N]   = [ssid, 0, 0, noise, channel, bssid, 0, mode]
set -u

OUT="${WIFI_CLIENTS_OUT:-/www/ajax_wificlients.asp}"
TMP="$OUT.tmp"

clean() { printf '%s' "$1" | tr -d '"\\\n\r'; }

arpip() {
    ip=$(awk -v m="$1" 'toupper($4)==toupper(m) {print $1; exit}' /proc/net/arp 2>/dev/null)
    printf '%s' "${ip:-}"
}

leasename() {
    for f in /tmp/dhcp.leases /var/lib/misc/dnsmasq.leases /tmp/dnsmasq.leases; do
        [ -f "$f" ] || continue
        n=$(awk -v m="$1" 'toupper($2)==toupper(m) {print $4; exit}' "$f" 2>/dev/null)
        [ -n "$n" ] && [ "$n" != "*" ] && { printf '%s' "$n"; return; }
    done
    printf ''
}

channel_str() {  # from chanspec, e.g. "6l (0x1808)" -> "6", "36/160 (0x..)" -> "36/160"
    wl -i "$1" chanspec 2>/dev/null | awk '{print $1}' | sed 's/[^0-9/].*$//'
}

rssi_for() { wl -i "$1" rssi "$2" 2>/dev/null | awk '{print $1}'; }

rate_for() {  # rate_for <ifname> <mac> <tx|rx> -> Mbps
    k=$(wl -i "$1" sta_info "$2" 2>/dev/null \
        | sed -n "s/.*rate of last $3 pkt:[^0-9]*\([0-9][0-9]*\).*/\1/p" \
        | head -1)
    [ -n "${k:-}" ] || { printf '0'; return; }
    printf '%d' $((k / 1000))
}

uptime_for() {
    s=$(wl -i "$1" sta_info "$2" 2>/dev/null | sed -n 's/.*in network \([0-9]*\) seconds.*/\1/p' | head -1)
    s=${s:-0}
    printf '%d:%02d:%02d' $((s/3600)) $(((s%3600)/60)) $((s%60))
}

phy_for() {
    st=$(wl -i "$1" sta_info "$2" 2>/dev/null)
    case "$st" in
        *"HE Cap"*|*"HE cap"*)     printf 'HE' ;;
        *"VHT caps"*|*"VHT Cap"*)  printf 'VHT' ;;
        *"HT caps"*|*"HT Cap"*)    printf 'HT' ;;
        *) printf '' ;;
    esac
}

utilization() {  # busy % from the last chanim_stats row (header is line 2)
    u=$(wl -i "$1" chanim_stats 2>/dev/null | awk 'END {print $15}')
    case "${u:-}" in ''|*[!0-9]*) printf '0' ;; *) printf '%s' "$u" ;; esac
}

flags_for() {
    st=$(wl -i "$1" sta_info "$2" 2>/dev/null)
    a="_"; u="_"; p="_"; s="_"; t="_"
    case "$st" in *ASSOCIATED*) a="A" ;; esac
    case "$st" in *AUTHORIZED*) u="U" ;; esac
    case "$st" in *STBC*) t="T" ;; esac
    case "$st" in *SGI20*|*SGI40*|*SHORT*) s="S" ;; esac
    printf '%s%s%s%s%s' "$p" "$s" "$t" "$a" "$u"
}

emit_unit() {  # emit_unit <unit> <ifname>
    u=$1; ifc=$2
    ssid=$(clean "$(nvram get "wl${u}_ssid" 2>/dev/null)")
    bssid=$(wl -i "$ifc" bssid 2>/dev/null)
    case "$bssid" in *:*) ;; *) bssid="00:00:00:00:00:00" ;; esac
    ch=$(channel_str "$ifc"); [ -n "$ch" ] || ch="0"
    noise=$(wl -i "$ifc" noise 2>/dev/null | awk '{print $NF}')
    [ -n "${noise:-}" ] || noise=0

    util=$(utilization "$ifc")
    printf 'dataarray%d = ["%s","0","0","%s","%s","%s","%s","AP"];\n' \
        "$u" "$ssid" "$noise" "$ch" "$bssid" "$util"

    printf 'wificlients%d = [' "$u"
    first=1
    for mac in $(wl -i "$ifc" assoclist 2>/dev/null | awk '{print $2}'); do
        [ -n "$mac" ] || continue
        ip=$(arpip "$mac"); name=$(clean "$(leasename "$mac")")
        rssi=$(rssi_for "$ifc" "$mac"); [ -n "${rssi:-}" ] || rssi="?"
        rx=$(rate_for "$ifc" "$mac" rx); [ -n "${rx:-}" ] || rx=0
        tx=$(rate_for "$ifc" "$mac" tx); [ -n "${tx:-}" ] || tx=0
        [ "$first" = "1" ] || printf ','
        printf '["%s","%s","%s","","%s","%s","%s","%s","","%s","","%s"]' \
            "$mac" "$ip" "$name" "$rssi" "$rx" "$tx" "$(uptime_for "$ifc" "$mac")" \
            "$(phy_for "$ifc" "$mac")" "$(flags_for "$ifc" "$mac")"
        first=0
    done
    printf ',"-1"];\n'
}

emit_log() {  # plain-text station dump for the "low level details" box
    for ifc in $(nvram get wl_ifnames 2>/dev/null); do
        echo "=== $ifc  SSID: $(nvram get "$(unit_prefix "$ifc")ssid" 2>/dev/null) ==="
        for mac in $(wl -i "$ifc" assoclist 2>/dev/null | awk '{print $2}'); do
            [ -n "$mac" ] || continue
            wl -i "$ifc" sta_info "$mac" 2>/dev/null
            echo
        done
    done
}

unit_prefix() {  # unit_prefix <ifname> -> "wlN_"
    for i in 0 1 2 3; do
        if [ "$(nvram get "wl${i}_ifname")" = "$1" ]; then
            printf 'wl%d_' "$i"
            return
        fi
    done
    printf 'wl0_'
}

main() {
    {
        for ifc in $(nvram get wl_ifnames 2>/dev/null); do
            u=0
            for i in 0 1 2 3; do
                [ "$(nvram get "wl${i}_ifname")" = "$ifc" ] && u=$i
            done
            emit_unit "$u" "$ifc"
        done
    } >"$TMP" 2>/dev/null
    [ -s "$TMP" ] && mv "$TMP" "$OUT"

    # Second feed: the same station dump, embedded in the polled script as a JS
    # string. httpd only serves its own whitelisted static files without auth,
    # so a separate .txt/.js URL was a dead end; the poll is already
    # authenticated and already executes our script.
    LOGTMP="$OUT.log"
    emit_log 2>/dev/null | tr -d '%' \
        | awk 'BEGIN { printf "window.franklinWlText = \"" }
               { gsub(/\\/, "\\\\"); gsub(/"/, "\\\""); printf "%s\\n", $0 }
               END { print "\";" }' >"$LOGTMP"
    if [ -s "$LOGTMP" ]; then
        cat "$LOGTMP" >>"$OUT"
    fi
    rm -f "$LOGTMP"
}

main "$@"
