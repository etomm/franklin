#!/bin/sh
# Stop the agent and its watcher. Settings stay in nvram, binaries on the USB.
set -u
cru d snmp_watch 2>/dev/null
if [ -n "$(pidof snmpd 2>/dev/null)" ]; then
    kill "$(pidof snmpd)" 2>/dev/null
    echo "snmp: snmpd stopped"
else
    echo "snmp: snmpd not running"
fi
rm -f /tmp/snmpd.conf /tmp/snmpd.log 2>/dev/null
exit 0
