# Franklin — working rules

Franklin is a userland extension layer that brings gnuton/Merlin features to
stock ASUSWRT on a ZenWiFi XT9, from a USB stick, without flashing firmware.

```
franklin.yaml            composition (features + profile)
features/<id>/           feature.yaml, payload/ (layout IS the stick layout), hooks
core/boot/franklin-boot  runtime driver (generated copy lives on the stick)
tools/                   composer, catalog, deploy, audits
docs/                    architecture, feature catalog, policies
firmware/{xt8,gnuton-xt8}/rootfs   extracted vendor trees (not committed)
```

Build, verify, deploy:

```sh
python tools/franklin-compose.py --check
python tools/franklin-compose.py                 # build/usb
sh tools/deploy-usb.sh                           # reads a tar on stdin, prunes
ssh admin@<router> 'sh /tmp/mnt/FRANKLIN/franklin/features/<id>/start.sh'
```

## Rules

**1. Evidence, not intuition.** Read the vendor sources we have (ASUS XT9 GPL in
`xt9-gpl.tgz`, gnuton's repo). When a component is closed, compare binaries and
say so. Every claim about behaviour should name the file, symbol or test it
came from.

**2. Library overrides follow `docs/library-overrides.md`.** Stock's copy stays
unless gnuton exports a symbol stock lacks (or stock ships nothing). Code-level
differences alone are not a reason. Decide with `sh tools/lib-audit.sh <lib>` and
record the verdict. Current `SKIP_LIBS`: `libwlcsm libbwdpi libwebapi`.

**3. Never write authentication state on the live device.** No
`nvram set http_passwd`, no shadow edits, no login-counter games on a device
someone depends on. Reproduce on a throwaway httpd (`:8089`) with its own
`LD_PRELOAD`; keep `:80` out of experiments. If an experiment can lock the owner
out, do not run it.

**4. `nvram set` is persistent here.** This firmware flushes the RAM copy to
flash at shutdown, so an "uncommitted" write can survive a reboot. Treat every
`nvram set` as permanent; save the previous value first and restore it
explicitly.

**5. Deploys are additive.** `tar`/`cp` never delete. Use `tools/deploy-usb.sh`
(staging + prune + registry regeneration). After changing a verdict such as a
library override, delete the stale file on the stick too.

**6. Prefer the vendor's real code.** Reuse real binaries, real pages and real
sources; write the smallest glue that makes them run. Every page patch lives in
`features/web-ui/build.sh` with a comment saying which handler is broken and
why. No silent emulation.

**7. Page/handler breakage is expected on XT9.** gnuton's XT8 build mis-parses
XT9 `sta_info`, `get_all_accounts()` returns nothing, ASP sub-pages are missing.
When a page fails, check the handler/ASP output *and* the served HTML before
blaming the UI.

**8. Test states, not folklore.** Verify on the node: `boot.log`, `pidof`,
`:80` probes, page bytes, symbol/`LD_PRELOAD` environments. Say what was
verified and what was not.

**9. Keep the tree consistent.** After adding or changing a feature:
`python tools/feature-catalog.py`, `python tools/parity-sync.py --check`,
`python tools/franklin-compose.py --check`. Feature ids are dashed
(`franklin-rc`); ASUS identifiers keep their underscores (`restart_snmpd`).

**10. Secrets and local detail never go into commits** (see the global rules):
no hostnames, paths, credentials or device-specific endpoints. Use placeholders.
