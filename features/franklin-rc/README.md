# franklin-rc

The companion for rc actions stock firmware does not implement. Not an rc
reimplementation: a dispatcher plus one thin handler per action, reusing
gnuton's own binaries and sources.

## The problem

Stock `rc` is pid 1:

```
/proc/1/exe -> /sbin/rc
```

It is started by the kernel, has no external API, and its action channel is
internal (`notify_rc(action)` → nvram `rc_service` + signal to itself). A
companion process therefore *cannot* subscribe to it, and a wrapper over
`/sbin/rc` is never called again.

That is why pages whose Apply sends an action stock does not know — the SNMP
page sends `restart_snmpd`, the NFS page `restart_nfsd` — silently do nothing
even though the nvram values are saved.

## The seam

The httpd we serve is gnuton's, and it resolves the rc trigger at load time:

```
$ nm -D gnuton/httpd | grep notify
         U notify_rc          # undefined: supplied by libshared
$ nm -D gnuton/libshared.so | grep notify_rc
00031420 T notify_rc
```

So the shim is an `LD_PRELOAD` library that defines `notify_rc` and looks the
real one up with `dlsym(RTLD_NEXT, ...)`:

```
page Apply ──► apply.cgi ──► notify_rc(action)
                                 │
                       libfranklin_rc.so
                        ├── action in the table ──► franklin-rc <action>
                        └── otherwise ───────────► real notify_rc (stock rc)
```

- Dispatch is fire-and-forget (fork + exec), like rc actions themselves, so
  httpd never blocks.
- The action **table is generated at build time** from `actions/*.sh`: adding a
  handler needs no C change and no change to the shim's build.
- All seven variants are intercepted (`notify_rc`, `*_after_wait`,
  `*_and_wait`, `*_and_wait_1min`, `*_and_wait_2min`, `*_after_period_wait`,
  `*_and_period_wait`). The wait arguments come from libshared's thunks:
  `period_wait` takes the seconds, the others have fixed values (15/30/10/60/120).
  For Franklin actions the companion runs fire-and-forget instead of blocking
  httpd on rc's wait.

## Files

```
src/shim.c                 notify_rc interposition + action table lookup
build.sh                   generates src/actions.h, cross-compiles the shim
actions/<action>.sh        one handler per action; thin glue
payload/bin/franklin-rc    dispatcher: franklin-rc <action> [args]
test/run.sh                host-side test of both dispatch directions
```

Handlers live in the feature payload (`features/franklin-rc/actions/` on the
stick) so they are versioned with the shim that calls them.

## Writing a handler

```sh
#!/bin/sh
# rc action `restart_nfsd`
set -u
[ -n "${FRANKLIN_ROOT:-}" ] || FRANKLIN_ROOT=$(cd "$(dirname "$0")/../../.." && pwd)
exec /bin/sh "$FRANKLIN_ROOT/features/nfs/start.sh"
```

The filename **is** the action name (`restart_nfsd.sh` → `restart_nfsd`), so it
must match the `action_script` value in the page's form exactly — those are
ASUS identifiers and keep their underscores (`restart_snmpd`, not
`restart-snmpd`).

Rebuild and redeploy to publish it:

```sh
sh features/franklin-rc/build.sh             # regenerates the table + shim
python tools/franklin-compose.py && deploy
```

`franklin-rc <action>` also works by hand on the router; every invocation is
logged to `franklin/log/franklin-rc.log`.

## Current actions

| action | handler does |
|---|---|
| `restart_snmpd` | regenerates `/tmp/snmpd.conf` from nvram and restarts the gnuton `snmpd` |

## Verification

```sh
sh features/franklin-rc/test/run.sh          # host: no router needed
grep -a LD_PRELOAD /proc/$(pidof httpd)/environ   # shim really loaded
franklin-rc restart_snmpd; tail franklin/log/franklin-rc.log
```
