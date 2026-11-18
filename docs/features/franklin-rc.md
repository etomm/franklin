# franklin-rc (companion for missing rc actions)

**Category:** System  
**Modes:** all  
**Status:** `implemented`  
**Kind:** franklin-feature  
**Required:** no  
**Upstream:** gnuton / Asuswrt-Merlin

## Dependencies

- [boot-hook](boot-hook.md)

## Build / install (separable)

Franklin addition: install on USB and start from the boot hook.

## What it does

Runs the rc actions stock firmware does not implement, when a page asks for them.

## How gnuton implements it

gnuton's rc implements more actions (restart_snmpd, restart_nfsd, ...); stock rc ignores anything it does not know.

## Requirements

`boot-hook`; the httpd wrapper from `web-ui-overlay` loads the shim; `actions/<action>.sh` handlers.

## Franklin approach

Stock rc is pid 1, so it cannot be patched or subscribed to. The gnuton httpd we serve resolves `notify_rc()` dynamically from libshared, so a small LD_PRELOAD shim intercepts it: actions Franklin implements go to `franklin-rc <action>`, everything else is forwarded to the real `notify_rc` untouched. Handlers are thin glue over gnuton's own binaries/sources; the action table is generated from the handler filenames at build time.

## Tested / verified

On the XT9: the SNMP page's Apply (action_script=restart_snmpd) now restarts the agent immediately instead of waiting for a poller; unknown actions still reach stock rc.

## Risks / notes

Handlers run fire-and-forget, so an action whose page expects rc-style wait semantics returns immediately; the wait arguments themselves are preserved for actions forwarded to stock rc.

## Why this kind (evidence)

See the parity table and dependencies above.

## Links / sources

- `docs/features/franklin-rc.md`
- `features/franklin-rc/README.md`
- `usr/lib/libshared.so (notify_rc)`
