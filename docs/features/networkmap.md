# Network Map / client list

**Category:** Monitoring  
**Modes:** all  
**Status:** `tested`  
**Kind:** workaround  
**Required:** no  
**Upstream:** gnuton networkmap daemon; Franklin needs a shm-size workaround

## Dependencies

- [boot-hook](boot-hook.md)
- [franklin-mount](franklin-mount.md)

## Build / install (separable)

Run gnuton networkmap (creates shm 0x3e9 at 198168) or fix shm size.

## What it does

Connected clients (wired/wireless), names, IPs, mesh topology.

## How gnuton implements it

`networkmap` daemon + httpd page `index.asp`/`device-map`; the daemon also writes `/jffs/nmp_cl_json.js` with the client list.

## Requirements

gnuton `networkmap` binary; `franklin-mount` (to bind it over the stock path); shm key 0x3e9 sized 198168 (gnuton) instead of 197916 (stock).

## Franklin approach

Workaround: bind gnuton networkmap over `/usr/sbin/networkmap`, clear the stale shm segment, start the daemon (stock's service actions are no-ops) and verify the 198168 layout before restarting httpd.

## Tested / verified

Verified on the XT9: shm 0x3e9 = 198168, gnuton daemon running, `/jffs/nmp_cl_json.js` rewritten with 14 KB of clients.

## Risks / notes

Stock allocates a smaller struct, so mixing binaries breaks the list; the old shm segment must be removed or the daemon reuses the wrong size.

## Why this kind (evidence)

workaround: stock's networkmap allocates the smaller struct (197916 vs 198168), so the gnuton UI cannot read its client table; replacing the daemon binary is the only fix that keeps the UI's layout.

## Links / sources

- `docs/firmware-comparison.md`
