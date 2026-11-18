#!/bin/sh
# Advertise the capabilities the gnuton UI checks but stock does not claim.
#
# This feature is only the advertisement (one nvram string). The work behind
# each token lives in its own feature, and runtime rc actions stock lacks are
# handled by the `franklin-rc` companion.
#
# menuTree.js hides a page when httpd's get_ui_support() has no flag for it,
# and that flag comes from nvram `rc_support`. Stock XT9 lacks tokens gnuton
# expects, so those menus never appear.
#
# Runtime-only: no `nvram commit`, so a reboot regenerates the firmware string.
#
# Note on `wifiradar`: deliberately NOT advertised. gnuton ships WiFi_Insight.asp
# but the four pages it links to (visindex.asp, metrics.asp, channelcapacity.asp,
# configure.asp) exist nowhere in its firmware and are unknown to its httpd, so
# the menu would only lead to 404s. Verified against the gnuton rootfs.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
state="$root/state"
mkdir -p "$state"

TOKENS="nwtool usbX cake snmp"
# Tokens this feature may have added in the past; always stripped before
# re-adding, so editing TOKENS (or retiring one) takes effect on the next start.
MANAGED="wifiradar nwtool usbX cake snmp"

cur=$(nvram get rc_support 2>/dev/null)
[ -n "$cur" ] || { echo "ui-capabilities: rc_support empty, nothing to do"; exit 0; }

base=" $cur "
for t in $MANAGED; do
    base=$(printf '%s' "$base" | sed "s/ $t / /g")
done
# squeeze the spaces we introduced
base=$(printf '%s' "$base" | sed 's/  */ /g; s/^ //; s/ $//')

new="$base"
added=""
for t in $TOKENS; do
    case " $new " in
        *" $t "*) ;;
        *) new="$new $t"; added="$added $t" ;;
    esac
done

if [ "$new" = "$cur" ]; then
    echo "ui-capabilities: capabilities already advertised"
    exit 0
fi

nvram set rc_support="$new" 2>/dev/null
if [ "$(nvram get rc_support)" = "$new" ]; then
    echo "ui-capabilities: rc_support = ${added:-unchanged} (managed: $TOKENS)"
else
    echo "ui-capabilities: failed to set rc_support"
    exit 1
fi
