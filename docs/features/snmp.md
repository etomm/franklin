# SNMP agent

**Category:** Services  
**Modes:** all  
**Status:** `implemented`  
**Kind:** gnuton-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [ui-capabilities](ui-capabilities.md)
- [franklin-rc](franklin-rc.md)

## Build / install (separable)

See Franklin approach above; deploy from USB/boot hook.

## What it does

net-snmp agent exposing the router over SNMP v1/v2c/v3.

## How gnuton implements it

`snmpd` + net-snmp libraries + `Advanced_SNMP_Content.asp`.

## Requirements

`snmpd` and libnetsnmp*.so.35 (gnuton only), the `snmp` rc_support token for the page, a config file and a start hook.

## Franklin approach

Ships gnuton `snmpd` + its four net-snmp libraries, recreates the SONAME links, generates /tmp/snmpd.conf with the same rules gnuton's rc uses (agentAddress, createUser/rwuser for the admin user, ro/rw communities, sysName/sysLocation/sysContact) and runs the agent from nvram. A per-minute watcher applies UI changes because stock rc has no `restart_snmpd` action.

## Tested / verified

On the XT9 (AP-mode node): page visible once `snmp` is advertised, apply.cgi writes the nvram settings, snmpd starts and answers a GET on udp/161; disabling stops it; settings changed in the page are picked up within a minute.

## Risks / notes

Stock rc cannot honour the page's restart action, so changes are applied by the watcher (up to ~60 s delay). snmpd_wan only matters on router-mode firewalls.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/features/snmp.md`
- `features/snmp/README.md`
- `www/Advanced_SNMP_Content.asp`
- `usr/sbin/snmpd`
