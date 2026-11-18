#!/bin/sh
# Apply Franklin's UI policy to the served /www tree, reversibly.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
src="$root/features/ui-policy"
state="$root/state"
mkdir -p "$state"

menu=/www/require/modules/menuTree.js
[ -f "$menu" ] || { echo "ui-policy: $menu missing (web UI not mounted)"; exit 1; }

# Keep one pristine copy so stop.sh can undo every policy edit.
# `cat >` writes through the overlay correctly; busybox cp fails with
# "File exists" on a copied-up path.
[ -f "$state/menuTree.js.orig" ] || cat "$menu" > "$state/menuTree.js.orig"

. "$src/policy.sh"

changed=""
if ! policy_traffic_analyzer; then
    echo "ui-policy: failed to expose Traffic Analyzer"
    exit 1
fi
changed="traffic-analyzer"

if [ -n "$changed" ]; then
    echo "ui-policy: applied ($changed); AP-mode policy on $menu"
else
    echo "ui-policy: nothing to do"
fi
exit 0
