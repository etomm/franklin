# SNMP

**Category:** Services  
**Modes:** all  
**Status:** `planned`  
**Upstream:** gnuton / Asuswrt-Merlin

## What it does

SNMP agent for monitoring (net-snmp).

## How gnuton implements it

`snmpd` (net-snmp) + `Advanced_SNMP_Content.asp`.

## Requirements

`snmpd` binary (in gnuton /usr/sbin; not stock), config, boot hook.

## Franklin approach

Copy gnuton `snmpd` + deps, run from boot hook, expose page.

## Tested / verified

gnuton has `snmpd`; not yet run.

## Risks / notes

Library deps; low risk.

## Links / sources

- `usr/sbin/snmpd`
- `www/Advanced_SNMP_Content.asp`
