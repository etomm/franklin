#!/bin/sh
# Franklin UI policy: the list of deliberate deviations from gnuton's UI.
#
# Each entry is a description plus the edit. Keep them small, reversible, and
# documented here - this file is the policy, not a pile of fixes.
#
# Environment: the router is an AiMesh node in AP mode (sw_mode=3). gnuton's
# menuTree hides sections that only make sense on a router; Franklin exposes
# the ones whose pages still work on a node.

MENU_JS=/www/require/modules/menuTree.js

# 1. Traffic Analyzer (holds Traffic Monitor tabs).
#    gnuton hides it in AP mode; the tabs (realtime / 24h / daily / monthly)
#    exist and can be fed on a node. Reason: product decision.
policy_traffic_analyzer() {
    [ -f "$MENU_JS" ] || return 0
    # No sed -i / rename: on the overlay, replacing the file fails where
    # rewriting it in place works. Filter to a temp file, then cat it back.
    grep -v 'retArray.push("menu_TrafficAnalyzer");' "$MENU_JS" > /tmp/menuTree.policy 2>/dev/null || return 1
    cat /tmp/menuTree.policy > "$MENU_JS"
    rm -f /tmp/menuTree.policy
    ! grep -q 'retArray.push("menu_TrafficAnalyzer");' "$MENU_JS"
}
