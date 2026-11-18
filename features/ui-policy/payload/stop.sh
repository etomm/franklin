#!/bin/sh
# Revert Franklin's UI policy: restore the pristine menuTree.js.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
orig="$root/state/menuTree.js.orig"
menu=/www/require/modules/menuTree.js

if [ -f "$orig" ] && [ -f "$menu" ]; then
    cat "$orig" > "$menu"
    rm -f "$orig"
    echo "ui-policy: restored original menuTree.js"
else
    echo "ui-policy: nothing to restore"
fi
exit 0
