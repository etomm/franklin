#!/bin/sh
# Start (or reconfigure) the SNMP agent from nvram, and schedule the watcher.
#
# The gnuton page (Advanced_SNMP_Content.asp) saves its settings through
# apply.cgi, which stock firmware does write to nvram, and then runs
# `restart_snmpd` — an rc action stock does not have. So the settings take
# effect here, either at boot or within a minute via watch.sh.
set -u
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi
root="$FRANKLIN_ROOT"
src="$root/features/snmp"
. "$src/lib.sh"

bin="$root/opt/sbin/snmpd"
libdir="$root/opt/lib/gnuton"
conf=/tmp/snmpd.conf
logf=/tmp/snmpd.log
state="$root/state"
mkdir -p "$state"

[ -x "$bin" ] || {
    echo "snmp: $bin missing (payload/opt not composed?)"
    exit 1
}

# Always keep the watcher scheduled: a disabled agent must still notice being
# switched on from the UI without a reboot.
cru d snmp_watch 2>/dev/null
cru a snmp_watch "* * * * * $src/watch.sh" 2>/dev/null

if snmp_running; then
    kill "$(pidof snmpd)" 2>/dev/null
    i=0
    while snmp_running && [ "$i" -lt 10 ]; do
        sleep 1
        i=$((i + 1))
    done
fi

snmp_settings_hash >"$state/snmp.hash"

if ! snmp_enabled; then
    echo "snmp: disabled (snmpd_enable != 1)"
    exit 0
fi

snmp_link_libs "$libdir"
snmp_write_conf "$conf"

LD_LIBRARY_PATH="$libdir:$root/opt/lib/gnuton${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    "$bin" -c "$conf" -Lf "$logf" >/dev/null 2>&1

i=0
while ! snmp_running && [ "$i" -lt 10 ]; do
    sleep 1
    i=$((i + 1))
done

if snmp_running; then
    echo "snmp: snmpd running (pid $(pidof snmpd), community $(nvram get roCommunity 2>/dev/null))"
else
    echo "snmp: snmpd failed to start (see $logf)"
    exit 1
fi
