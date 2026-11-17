# Web UI overlay (bind-mount httpd + /www) — workaround

**Category:** UI  
**Modes:** all  
**Status:** `tested`  
**Kind:** workaround  
**Required:** no  
**Upstream:** n/a — Franklin workaround (gnuton needs none: its httpd is in the image)

## Dependencies

- [web-ui](web-ui.md)
- [boot-hook](boot-hook.md)

## Build / install (separable)

Franklin workaround: deploy from USB/boot hook (see Franklin approach).

## What it does

Franklin's mechanism for presenting the gnuton UI on unmodified stock firmware: bind-mount gnuton's `httpd` and replace `/www`, with a parallel httpd on :8088 as the fallback.

## How gnuton implements it

gnuton does not need this: its `httpd` and `/www` are simply part of the firmware image.

## Requirements

gnuton httpd + /www + differing libs (see web-ui); `acc_num` consistency; optional: the networkmap feature for a populated client list.

## Franklin approach

Workaround that exists only because stock is not gnuton: run gnuton httpd from USB on :8088 while testing, then bind-mount over stock for the 95%-gnuton experience. Must be reversible at runtime (unmount restores stock).

## Tested / verified

gnuton httpd + /www run on stock XT9 on :8088 with stock UI untouched; `acc_num=0` fix makes Advanced_System_Content load. Bind mode is opt-in via state/web-ui-overlay.bindwww and untested on the device yet.

## Risks / notes

httpd/lib ABI coupling; a failed bind-mount can leave no UI — always keep the stock httpd running and the overlay reversible.

## Why this kind (evidence)

workaround: verified by running gnuton binaries on stock. Stock has no equivalent mechanism; gnuton needs none.

## Links / sources

- `docs/firmware-comparison.md`
- `docs/xt9-kernel-notes.md`
