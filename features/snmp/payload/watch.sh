#!/bin/sh
# Apply SNMP settings changed in the UI, and restart a dead agent.
# Stock rc has no restart_snmpd, so the page's apply only writes nvram.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
src="$root/features/snmp"
. "$src/lib.sh"

state="$root/state"
prev=$(cat "$state/snmp.hash" 2>/dev/null || echo "")
now=$(snmp_settings_hash)

if [ "$now" != "$prev" ]; then
    echo "snmp: settings changed, applying"
    exec /bin/sh "$src/start.sh"
fi

if snmp_enabled && ! snmp_running; then
    echo "snmp: enabled but not running, starting"
    exec /bin/sh "$src/start.sh"
fi
exit 0
