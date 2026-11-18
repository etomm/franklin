# test-access — unauthenticated read-only UI, testing only

> **Security:** while this feature runs, any device on the LAN can read the
> router's web UI without a password. It is opt-in, not part of any normal
> composition, and must be stopped (or the router rebooted) after a test run.
> It cannot apply settings — POST/apply still requires a logged-in session.

## Why it exists

Test-driven work on the UI needs pages it can fetch, render and inspect without
a human logging in. On this node a login is impossible headlessly: it is an
AiMesh node (`sw_mode=3`), the local admin password is controller-managed, and
`login.cgi` never compares credentials at all (verified by hooking the strings,
nvram and pf-nvram lookups httpd imports — none are consulted during a login
attempt).

## The seam

Stock httpd has a first-time-setup exemption for handlers flagged
`MIME_EXCEPTION_NOAUTH_FIRST` (httpd.c):

```c
if ((mime_exception & MIME_EXCEPTION_NOAUTH_FIRST) && !x_Setting) {
    /* skip auth */
}
```

`x_Setting=1` means "configured". Setting it to `0` (runtime only) makes the
`.asp` pages readable without a session:

```
x_Setting=1 → GET /Advanced_SNMP_Content.asp  → 302 Main_Login.asp
x_Setting=0 → GET /Advanced_SNMP_Content.asp  → 200, real page
```

Verified on the node: `/index.asp`, `/Advanced_SNMP_Content.asp`,
`/Main_TrafficMonitor_last24.asp`, `/Tools_Sysinfo.asp` all return their real
content; `/Advanced_System_Content.asp` does not (its handler is not flagged).

## What it deliberately does not do

- `/login.cgi` still fails → no session cookie is created.
- `POST /apply.cgi` still redirects to the login page → settings are not
  applied through the UI.

Actions are therefore not driven through the web layer in tests. Use the
companion directly, which is the same handler path the UI triggers:

```sh
franklin-rc restart_snmpd
```

If a future test really needs authenticated POSTs, that requires patching the
auth gate inside httpd (it is compiled in, not an imported symbol) — a separate,
larger piece of work.

## Use

```sh
python tools/franklin-compose.py --add test-access      # put it on the stick
sh /tmp/mnt/FRANKLIN/franklin/features/test-access/start.sh
# ... fetch pages, screenshot, verify ...
sh /tmp/mnt/FRANKLIN/franklin/features/test-access/stop.sh
```

`stop.sh` restores the saved value; nothing is committed, so a reboot also
restores the firmware's own value.
