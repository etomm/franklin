#!/bin/sh
# TEST ONLY: make the web UI readable without a login.
#
# httpd skips auth for the handlers flagged NOAUTH_FIRST while nvram
# `x_Setting` is 0 (first-time-setup path; see httpd.c:
#   if ((mime_exception & MIME_EXCEPTION_NOAUTH_FIRST) && !x_Setting) ...skip ).
# That covers the .asp pages, so a test runner can fetch and verify them.
# It does NOT cover /login.cgi or POST /apply.cgi, which still need a session.
#
# Runtime only: the original value is saved for stop.sh, and nothing is
# committed, so a reboot restores the firmware's value.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
state="$root/state"
mkdir -p "$state"

saved="$state/x_Setting.orig"
[ -f "$saved" ] || nvram get x_Setting >"$saved" 2>/dev/null

before=$(nvram get x_Setting 2>/dev/null)
nvram set x_Setting=0 2>/dev/null
after=$(nvram get x_Setting 2>/dev/null)

if [ "$after" = "0" ]; then
    echo "test-access: x_Setting $before -> 0 (UI readable without login)"
    echo "test-access: restore with stop.sh; POST/apply still needs a session"
else
    echo "test-access: failed to set x_Setting (still '$after')"
    exit 1
fi
exit 0
