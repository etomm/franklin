#!/bin/sh
# Advertise the capabilities the gnuton UI checks but stock does not claim.
#
# menuTree.js hides a page when httpd's get_ui_support() has no flag for it,
# and that flag comes from nvram `rc_support`. Stock XT9 lacks tokens gnuton
# expects (`wifiradar`, `nwtool`, `usbX`, `cake`), so those menus never appear.
#
# Runtime-only: no `nvram commit`, so a reboot regenerates the firmware string.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
state="$root/state"
mkdir -p "$state"

# Add tokens only for things Franklin really provides.
TOKENS="wifiradar nwtool usbX cake"

cur=$(nvram get rc_support 2>/dev/null)
[ -n "$cur" ] || { echo "partial-rc: rc_support empty, nothing to do"; exit 0; }

# Keep the firmware's own string so stop.sh can restore it.
[ -f "$state/rc_support.orig" ] || printf '%s\n' "$cur" >"$state/rc_support.orig"

new="$cur"
added=""
for t in $TOKENS; do
    case " $new " in
        *" $t "*) ;;
        *) new="$new $t"; added="$added $t" ;;
    esac
done

if [ -z "$added" ]; then
    echo "partial-rc: capabilities already advertised"
    exit 0
fi

nvram set rc_support="$new" 2>/dev/null
if [ "$(nvram get rc_support)" = "$new" ]; then
    echo "partial-rc: added$added"
else
    echo "partial-rc: failed to set rc_support"
    exit 1
fi
