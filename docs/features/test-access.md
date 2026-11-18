# test-access (unauthenticated read-only UI, testing only)

**Category:** System  
**Modes:** all  
**Status:** `implemented`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [ui-capabilities](ui-capabilities.md)

## Build / install (separable)

Franklin addition: install on USB and start from the boot hook.

## What it does

TEST ONLY: lets a test runner fetch web UI pages without logging in.

## How gnuton implements it

n/a - stock httpd behaviour, reached through its first-time-setup exemption.

## Requirements

`ui-capabilities` (the page must exist in the menu/pages); runtime nvram `x_Setting`.

## Franklin approach

Sets nvram `x_Setting=0` at start (the value httpd treats as 'not configured'): handlers flagged NOAUTH_FIRST then skip authentication, so .asp pages are readable. Restores the saved value on stop; never committed. POST/apply and login.cgi still require a session, so actions are driven via franklin-rc.

## Tested / verified

On the XT9: with x_Setting=0, /index.asp, /Advanced_SNMP_Content.asp, /Main_TrafficMonitor_last24.asp and /Tools_Sysinfo.asp return their real content without a login; /login.cgi and POST /apply.cgi still redirect to the login page.

## Risks / notes

SECURITY: while running, any LAN client can read the UI without a password. Opt-in only (--add test-access), never composed by default; stop it or reboot after use.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/features/test-access.md`
- `features/test-access/README.md`
