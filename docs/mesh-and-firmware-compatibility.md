# AiMesh and firmware compatibility (why "upgrade all nodes")

Short answer: **AiMesh is a closed firmware control plane, not a userland
feature**, so gnuton adds nothing to it. The "upgrade every node" advice is
about the mesh handshake and the shared configuration schema, not about
features. This document explains what that means for Franklin.

## What the mesh actually is

Verified from the extracted stock XT8 rootfs and gnuton rootfs (same files
present in both, no gnuton-only mesh components):

| Component | Role |
|---|---|
| `amas`, `amas_lib`, `amas_ipc`, `amas_lanctrl`, `amas_wlcconnect`, `amas_ssd*`, `amas_bhctrl`, `amas_portstatus`, `amas_status`, `amas_misc`, `amas_adtbw` | ASUS mesh agent: onboarding, topology, backhaul/fronthaul control, node status |
| `cfg_server` / `cfg_client` | the controller pushes configuration (nvram keys, mount lists) to nodes and re-applies it |
| `bsd`, `dhd.ko`, `acsd2`, `wlconf`, `archer` | wireless/backhaul drivers and channel management |
| `AiMesh*.asp`, `aimesh_*.html`, `amassearch_page.html` | UI on top of the above |

None of these are in the ASUS GPL drop in a rebuildable form, none are loadable
modules, and none are userland tools we could ship on a USB stick. That is why
the feature catalog has **zero mesh features**: `aimesh` is `Kind: stock`, and
the only Franklin-relevant mesh facts are constraints on our design.

## Why gnuton/Merlin says to upgrade every node

1. **Versioned handshake.** `amas`/`cfg_server` exchange a firmware/build
   identity. A controller and node on different builds can refuse to form,
   drop the node, or keep re-syncing it. Merlin's own changelog makes the same
   point from the other direction: nodes running Merlin need manual updates,
   because automatic live-update of non-ASUS nodes is not supported.
2. **Shared configuration schema.** The controller pushes nvram keys and mount
   lists to the node (`cfg_server` → `cfg_client`). If the schema differs
   between builds, keys are silently ignored or the node is reset to defaults
   repeatedly.
3. **Firmware push is image-based.** `AiMesh_Node_FirmwareUpgrade.asp` sends
   the controller's firmware file to each node, and a node only accepts an
   image for its own model. So "upgrade the mesh" really means "flash the same
   build on every node", which for a third-party build has to be done per node
   by hand.
4. **Mixed builds break UI expectations.** The router's UI (in gnuton's case,
   a different `/www`) assumes the node reports the capabilities of the same
   release.

Nothing in that list is a gnuton feature. It is true of stock ASUSWRT too:
ASUS recommends keeping all AiMesh nodes on the same firmware version.

## What this means for Franklin

Our test device is an **AiMesh node in AP mode**, which has consequences:

- **No controller role.** DHCP, DNS, firewall/NAT, VPN endpoints, WAN shaping
  and AiProtection live on the main router. Franklin features that need those
  modes are marked `Router` in their plans and simply do not apply on the node.
- **Node settings are owned by the controller.** Anything Franklin writes into
  nvram can be overwritten by `cfg_server` at any time (and again after a
  reboot or a mesh re-sync). Franklin state must live on USB/`/jffs` and be
  re-applied by the boot hook, never assumed to persist in nvram.
- **The node UI is reached through the controller.** The mesh shows node pages
  from the router's web UI. Our gnuton `httpd` + `/www` overlay is therefore
  only visible when the node is addressed directly; the router keeps serving
  its own pages.
- **Runtime overlays die on reboot/upgrade.** Bind mounts and processes started
  by hand do not survive; the boot hook is what re-creates them. This is the
  same property that makes the boot hook the only `Required` feature.
- **Never touch the mesh interface.** Franklin must not replace or patch
  `amas*`, `cfg_server`/`cfg_client`, `bsd`, `dhd.ko`, `acsd2`, or the reported
  firmware/build identity. Those are exactly the pieces the handshake checks.

## Rules for Franklin on a mesh node

1. Do not modify build/version identity (`buildno`, `firmware_version`,
   `extendno`, model strings) — mesh compatibility checks compare them.
2. Do not persist configuration only in nvram; keep the source of truth on USB
   and let the boot hook re-apply it.
3. Make every hook idempotent: expect `cfg_server` to re-push settings and the
   controller to reboot the node.
4. Keep the web UI overlay reversible (unmount restores the stock UI), because
   the controller may serve node pages at any time.
5. Treat firmware upgrades as a full reset of runtime state and re-verify the
   overlay afterwards; Franklin cannot survive an image replacement.

## Re-check this document when

- the main router is switched to Router mode and Franklin is deployed there
  (then the controller-side UI and mesh pages matter),
- a firmware upgrade changes `amas`/`cfg_server`,
- you add a feature that writes nvram.

Reproduce the mesh-component check any time with:

```sh
python tools/parity-audit.py     # then read the "mesh" probes / gnuton-only list
```
