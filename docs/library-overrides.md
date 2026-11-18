# Library overrides: policy and evidence method

Franklin replaces `httpd` and some libraries from gnuton. Every replacement is
a risk: the library may be coupled to the firmware's own binaries or to a
closed blob. This document is the rule used to decide **keep stock** vs **ship
gnuton**, and the method that produces the evidence.

## The rule

| situation | verdict |
|---|---|
| stock does not ship the library | **ship gnuton** (no choice) |
| gnuton exports a symbol stock does not | **ship gnuton** (an importer may need it) |
| stock exports a symbol gnuton does not | **review** — do not fall back silently |
| export sets are equal | **keep stock** |
| …and the exported code is byte-identical too | keep stock, no doubt |

Code-level differences alone are **not** a reason to ship gnuton's build. The
two firmwares compile the same sources with different flags, so instruction
streams differ while behaviour does not. They are a signal for review, not a
verdict.

Add the library to `SKIP_LIBS` in `features/web-ui/build.sh` when the verdict is
**keep stock**. That list currently is:

```
libwlcsm libbwdpi libwebapi
```

- `libwlcsm`, `libbwdpi` — read hardware / proprietary DPI data; gnuton's XT8
  builds return nothing useful on the XT9.
- `libwebapi` — its password/API logic lives in a **prebuilt object**
  (`priv_webapi.o`, ASUS does not publish the source). Both firmwares export the
  same 101 symbols, and every symbol gnuton's binaries import exists in stock's
  copy. Shipping gnuton's build gives nothing and adds a closed blob that can
  drift.

## The method

```sh
sh tools/lib-audit.sh libwebapi     # one library
sh tools/lib-audit.sh --all         # every library gnuton ships
```

It compares `firmware/xt8/rootfs` with `firmware/gnuton-xt8/rootfs`:

1. locate the library in `lib/` and `usr/lib/` (both roots),
2. diff the exported symbol sets (`nm -D --defined-only`),
3. if the sets are equal, normalise and diff the disassembly of every exported
   function (`arm-linux-gnueabi-objdump`, addresses and PLT slots stripped),
4. print a verdict per the table above.

Runs in WSL/Debian (`binutils-arm-linux-gnueabi`).

## Worked example: libwebapi

```
exports: stock 101, gnuton 101 — identical sets
imports: every webapi symbol imported by gnuton's httpd/networkmap exists in stock's copy
code    : instruction streams differ (build flags); do_chpass / check_chpass_auth
          are the same length and the same logic in both
verdict : keep stock
```

What the source tells us: `libwebapi/Makefile` builds `webapi.o` (published
`webapi.c`) plus `priv_webapi.o` from `prebuild/<model>/`. `do_chpass` and
`check_chpass_auth` are declared `extern` in `webapi.h` and implemented in that
prebuilt object — hence no source anywhere (also absent from the XT9 GPL).

## Applying a "keep stock" verdict

1. add the name to `SKIP_LIBS` in `features/web-ui/build.sh`,
2. rebuild the delta (`sh features/web-ui/build.sh`),
3. compose and deploy,
4. **delete the stale copy** from the stick — the deploy is additive:
   `rm /tmp/mnt/FRANKLIN/franklin/opt/lib/gnuton/<lib>`,
5. restart httpd (the wrapper's `LD_LIBRARY_PATH` then resolves to `/usr/lib`).

## What this method cannot decide

Function bodies are compared, not behaviour, and prebuilt objects are opaque.
Where a specific page misbehaves and a library is suspected, the decisive test
remains a targeted runtime check (for passwords: whether `pw_dec(nvram
http_passwd)` equals the typed value), not a bigger diff.
