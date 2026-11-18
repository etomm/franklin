#!/bin/sh
# rc action `restart_snmpd` (the SNMP page's Apply button sends this).
# Stock rc has no such action; Franklin regenerates the config and restarts
# the gnuton agent.
set -u
[ -n "${FRANKLIN_ROOT:-}" ] || FRANKLIN_ROOT=$(cd "$(dirname "$0")/../../.." && pwd)
exec /bin/sh "$FRANKLIN_ROOT/features/snmp/start.sh"
