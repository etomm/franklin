---
name: vendor-analysis
description: Compare stock ASUSWRT and gnuton/Merlin components to decide whether a library must be replaced, or to explain why a vendor page/handler misbehaves. Use when a feature needs a vendor binary/library, when a UI page fails for no clear reason, or when a "gnuton vs stock" difference is suspected.
---

# Vendor analysis (stock vs gnuton)

Two firmwares are in play: the router's stock ASUSWRT XT9 and gnuton's XT8 build
that Franklin ships parts of. Most "weird" behaviour is one of: a closed blob
that differs, an ASP handler that emits nothing on XT9, or state we created.
This skill is the procedure to tell them apart.

## 1. Establish what exists

```sh
# sources: ASUS XT9 GPL (WSL)
tar tzf /root/xt9-gpl.tgz | grep -i <component>

# symbols of a vendor binary/library
nm -D --defined-only firmware/gnuton-xt8/rootfs/usr/lib/<lib>.so | head
nm -D firmware/gnuton-xt8/rootfs/usr/sbin/<bin> | grep ' U '   # imports
```

If the source is published, read it. If it is not, say so explicitly — do not
infer behaviour from names. gnuton builds some closed parts from prebuilt
objects (`libwebapi/Makefile` links `prebuild/<model>/priv_webapi.o`).

## 2. Decide library overrides (the policy)

```sh
sh tools/lib-audit.sh <libname>     # one
sh tools/lib-audit.sh --all         # everything gnuton ships
```

Verdict rule (full text: `docs/library-overrides.md`):

| evidence | verdict |
|---|---|
| stock has no such library | ship gnuton |
| gnuton exports a symbol stock lacks | ship gnuton |
| export sets equal | **keep stock** |
| export sets equal and code identical | keep stock, confidently |

Code differences alone are **not** a verdict: both firmwares compile the same
sources with different flags. Keep stock (`SKIP_LIBS` in
`features/web-ui/build.sh`) unless a symbol forces otherwise.

Applying "keep stock" is a deletion, not an addition:

```sh
# after rebuild + deploy (deploy is additive)
rm /tmp/mnt/FRANKLIN/franklin/opt/lib/gnuton/<lib>.so
/sbin/service restart_httpd      # wrapper's LD_LIBRARY_PATH now finds /usr/lib
```

## 3. Diagnose a failing page

1. Fetch the **served** page with a session (ASP is rendered server-side):
   `python …` POST `/login.cgi`, then GET the page; grep the rendered JS.
   Example found this way: `var accounts = [[]][0];` — the ASP handler
   `get_all_accounts()` returned nothing, so the dialog sent no username.
2. Check the request the page makes (endpoint, encoding, hashing). 20 lines of
   JS in `js/httpApi.js` often explain a 401/402: `chpass` sends
   `md5(username)` / `md5(password)`, base64 for new values.
3. Only then look at the handler/library. A status code guesses nothing:
   reproduce it with a scripted request before touching code.

## 4. Safe runtime experiments

- Never experiment on `:80` with authentication state (`http_passwd`,
  `/etc/shadow`, login counters). The owner gets locked out.
- Start a throwaway instance instead:

```sh
cd /tmp/mnt/FRANKLIN/franklin/state/overlay/www-mnt
LD_LIBRARY_PATH=/tmp/mnt/FRANKLIN/franklin/opt/lib/gnuton \
  LD_PRELOAD=/tmp/probe.so \
  /tmp/mnt/FRANKLIN/franklin/opt/bin/gnuton-httpd -p 8089 &
```

- Probe libraries from inside the real process with an `LD_PRELOAD` shim
  (constructor or a hook on an imported symbol). Remember: only symbols resolved
  through the dynamic linker are hookable (`U` in `nm -D`); code compiled into
  the binary is not.
- Cross-compile shims against the *target* libdl so the glibc requirement stays
  ≤ 2.26:

```sh
arm-linux-gnueabi-gcc -shared -fPIC -nostdlib -o probe.so probe.c \
  firmware/xt8/rootfs/lib/libdl.so.2 -lc -lgcc
```

- State on this firmware is sticky: `nvram set` can survive a reboot. Save and
  restore values explicitly; verify with `nvram savefile` (some keys are hidden
  from `nvram get`/`show` but present in the savefile).

## 5. Report

Give: the component, the evidence (symbols, source path, rendered HTML, test),
the verdict, and the concrete change applied. If a verdict is "keep stock", say
which stale file was deleted on the stick.
