#!/bin/sh
# franklin-rc has no daemon: it is the dispatcher plus the httpd shim. This
# hook only makes sure the pieces are usable after a composition (binaries are
# copied without the executable bit on Windows-hosted builds).
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"

chmod 755 "$root/bin/franklin-rc" "$root"/features/franklin-rc/actions/*.sh 2>/dev/null

[ -x "$root/bin/franklin-rc" ] || { echo "franklin-rc: dispatcher missing"; exit 1; }
[ -f "$root/opt/lib/gnuton/libfranklin_rc.so" ] || {
    echo "franklin-rc: shim missing (build.sh not run?)"; exit 1; }

actions=$(cd "$root/features/franklin-rc/actions" 2>/dev/null && ls -1 *.sh 2>/dev/null | sed 's/\.sh$//' | tr '\n' ' ')
echo "franklin-rc: ready; actions: ${actions:-none}"
echo "franklin-rc: shim is loaded by the httpd wrapper (web-ui-overlay)"
exit 0
