# Franklin — a FrankenMerlin for stock ASUSWRT

Status: idea / research notes / future project  
Date: 2026-11-09  
Working name: **Franklin** (FrankenMerlin)  
Primary test device: ASUS ZenWiFi XT9, stock ASUSWRT `3.0.0.4.388_24854`, AP mode

---

## 0. Decision update (2026-11-09, later in the same session)

After testing the Mango path in practice, the production direction changed:

- The Mangos **can** bridge VLAN 100 and pass traffic, but the setup was
  unreliable in daily use and added 2.4 GHz clutter to the ASUS mesh.
- The Wi-Fi SSID was initially left in `br-lan`; hostapd was configured for
  `br-dolguldur`, but the running interface stayed in `br-lan` until a full
  `wifi down; wifi up`. This made the solution feel fragile and hard to trust.
- The Mangos are being removed from the production path.

New direction:

1. **Ditch the Mangos.**
2. Keep the **ASUS XT9/XT8 mesh** for main Wi-Fi.
3. Use **ASUS Guest Network** for guest/IoT where NAT/isolation is enough.
4. Keep **VLAN 100 / Dolguldur** for **wired** paths only, unless a proper
   VLAN-capable AP is added later.
5. Do **not** try to make stock ASUSWRT create arbitrary VLAN-tagged Wi-Fi
   SSIDs. Stock firmware cannot do that; the `ethswctl`/IPTV hack only affects
   wired switch ports.

Important constraint discovered:

- The XT9/XT8 can pass VLAN 100 between **wired** ports with the
  `ethswctl`/IPTV/boot-hook workaround.
- They cannot put a Wi-Fi SSID on VLAN 100 without a much deeper hostapd /
  `vlanctl` FrankenMerlin, which is not recommended for reliability.

So Franklin remains interesting for **wired VLANs, boot hooks, Entware,
diagnostics and a custom UI**, but it is not the path to VLAN-tagged Wi-Fi on
the XT9/XT8.

---

## 1. What Franklin is

Franklin is a **userland extension layer for stock ASUSWRT** that provides
Merlin-like capabilities without flashing unsupported firmware:

- a real boot hook,
- a package ecosystem,
- persistent scripts,
- scheduled jobs,
- a custom web control panel,
- access to low-level ASUS/Broadcom tools (`ethswctl`, `vlanctl`, `brctl`).

It is **not** a firmware replacement. It does not patch the kernel, wireless
drivers, switch drivers, calibration data, or ASUSWRT’s compiled web backend.

Franklin is intended for devices where:

- the vendor firmware works,
- a supported Merlin/gnuton build does not exist,
- the device has USB and/or writable `/jffs`,
- the user wants automation and custom controls without a risky cross-flash.

---

## 2. Why this exists

The XT9 is close to the XT8, but not identical, and the gnuton XT8 build does
not officially support the XT9. Cross-flashing is unsafe. At the same time,
the stock firmware exposes enough hooks to run a meaningful extension layer.

The motivating problem was VLAN 100 / Dolguldur egress and switch behavior:

- Proxmox bond → managed switch → XT9 AP → Mango.
- The XT9 needed specific switch state (`hw-switching` + `softswitch` map).
- After reboot the state changed and VLAN 100 broke.
- NVRAM `script_usb*` hooks did not run at boot on this firmware.
- The `asusware.arm` app-folder mechanism **did** run at boot and was verified.

That discovery is the foundation of Franklin.

---

## 3. Verified facts from the XT9

### Firmware / platform

```text
Model:      ZenWiFi XT9
Firmware:   3.0.0.4.388_24854
Mode:       Access Point (AP)
Kernel:     4.19.183
Arch:       armv7l
Rootfs:     read-only squashfs
Persistent: /jffs
Tmpfs:      /tmp, /root, /var
```

### Boot hook that works

The firmware supports the ASUS app-folder mechanism:

```text
USB partition root/
└── asusware.arm/
    ├── .asusrouter
    ├── etc/init.d/S99xt9-log
    └── lib/ipkg/info/xt9-log.control   ("Enabled: yes")
```

At boot the firmware logs:

```text
asusware: umount partition /dev/sda...
asusware: Automatically scan partition /dev/sda...
asusware: re-mount partition /dev/sda...
asusware: done.
```

and runs the `S*` script. Verified log:

```text
[Mon Nov  9 10:58:13 CET 2026] S99xt9-log start
```

`/tmp/opt` becomes a symlink to the USB `asusware.arm` directory. This is a
real boot hook and survives reboot as long as the USB stick is present.

### Hooks that did **not** work

These NVRAM variables were tested and did **not** run at boot on this firmware:

```text
script_boot
script_usbmount
script_usbhotplug
script_wan
script_ppp
script_firewall
```

`script_usbhotplug` may still run on physical USB insertion, but it is not a
boot hook.

### Switch-state tools

```sh
ethswctl -c hw-switching              # read: Enabled/Disabled
ethswctl -c hw-switching -o enable    # write
ethswctl -c softswitch                # read: soft-switching port map
ethswctl -c softswitch -i eth0 -o enable
ethswctl -c softswitch -i eth1 -o enable
```

Working sequence (order matters):

```sh
ethswctl -c hw-switching -o enable
ethswctl -c softswitch -i eth0 -o enable
ethswctl -c softswitch -i eth1 -o enable
```

Expected working state:

```text
hw-switching = Enabled
softswitch   = 120  (0x78)
```

Observed failure state:

```text
hw-switching = Enabled
softswitch   = 20   (0x14)
```

In the failure state VLAN 100 stopped working. Enabling `softswitch` before
`hw-switching` left the map at `321` and also failed. The order above is the
verified sequence.

### Web UI

- `/www` is read-only but overlayable with a bind mount.
- `/www/apply.cgi` does **not** exist.
- There are no `.cgi` files anywhere in the userland.
- `httpd` contains the strings `apply.cgi`, `apply_cgi`, and `start_apply`.
- Therefore, the ASP/apply backend is compiled into `/usr/sbin/httpd`.
- Page and menu replacement is easy; new backend actions require patching
  `httpd` or running a separate web server.

### Kernel / modules

```text
Kernel:   4.19.183
Vermagic: 4.19.183 SMP preempt mod_unload ARMv7 p2v8
Config:   /proc/config.gz available
```

Relevant config:

```text
CONFIG_NET_SCH_CAKE      is not set
CONFIG_NET_SCH_FQ_CODEL  = y
CONFIG_IFB               = y
CONFIG_NET_CLS_ACT       = y
CONFIG_NET_ACT_POLICE    = y
CONFIG_NET_ACT_GACT      = y
CONFIG_NET_ACT_MIRRED    = y
```

Implication:

- SQM with `fq_codel` and `ifb` is plausible with built-in kernel features.
- Cake would need a compatible `sch_cake.ko`.
- Generic modules may load if vermagic matches.
- Board/radio/switch modules (`dhd`, `bcm_enet`, `bcmvlan`, `archer`, `otp`)
  must not be copied from another model.

### XT8 vs XT9 hardware

They are the same family but not identical:

| Item | XT8 | XT9 |
|---|---|---|
| SoC | BCM6755, 4× 1.5 GHz | 4× 1.7 GHz (same family) |
| RAM | 512 MB DDR3 | 512 MB DDR4 |
| 5 GHz-1 | 2×2, 80 MHz, 1201 Mbps | 2×2, 160 MHz, 2402 Mbps |
| 5 GHz-2 | 4×4, 160 MHz, 4804 Mbps | 4×4, 160 MHz, 4804 Mbps |
| Class | AX6600 | AX7800 |
| LAN aggregation | No | Yes |

Neither has a 6 GHz band. The “larger band” is 5 GHz-1 at 160 MHz.

So: generic modules may be portable; calibration, RF, and switch specifics are
not.

### SSH

- The SSH public key was saved in ASUS settings and survives reboot.
- Key-based SSH works without distributing passwords.
- This enables external automation from `aglarond` or another always-on host.

---

## 4. Franklin architecture

```text
USB stick
├── asusware.arm/
│   ├── .asusrouter
│   ├── etc/init.d/
│   │   ├── S99franklin-boot          # boot hook
│   │   └── S99franklin-services      # optional service start
│   ├── lib/ipkg/info/
│   │   └── franklin-boot.control     # "Enabled: yes"
│   └── (Entware root if installed)
│       ├── bin/
│       ├── etc/
│       └── lib/
└── franklin/                          # project data / configs
    ├── bin/
    ├── etc/
    └── logs/

Stock ASUSWRT
├── /www overlay (optional)            # custom pages/menu
├── /sbin, /usr/sbin                   # stock tools
└── httpd                              # ASP/apply backend (not patched)

Franklin control plane
├── boot hook (asusware.arm)
├── cron/watchdog (Entware or script)
├── custom web UI on :8080 (lighttpd/uhttpd or static Go)
└── wrappers around ethswctl/vlanctl/brctl
```

### Design principles

1. **Do not patch core firmware** (`rc`, `init`, `httpd`, kernel, drivers)
   unless there is a recovery plan and a strong reason.
2. **Prefer userland.** Use `ethswctl`, `vlanctl`, `brctl`, Entware tools.
3. **Keep the stock UI working.** Overlay pages if needed, but do not depend
   on the stock UI for new actions.
4. **Persist on USB/jffs, not `/tmp`.**
5. **Fail visible.** Log to both `/tmp` and a persistent path during debugging.
6. **Recoverable by design.** SSH key in ASUS settings; console/reset path.

---

## 5. Phases

### Phase 0 — Inventory and safety

- Record firmware, kernel, model ID, `productid`, `odmpid`.
- Confirm console/reset recovery.
- Save SSH key in ASUS settings.
- Keep a known-good USB stick.
- Document the current switch state and how to restore it.

### Phase 1 — Boot hook (verified)

- Create `asusware.arm` on the USB.
- Add `.asusrouter`.
- Add `etc/init.d/S99franklin-boot`.
- Add `lib/ipkg/info/franklin-boot.control` with `Enabled: yes`.
- Script logs to `/tmp/franklin.log` and a persistent `/jffs/franklin.log`.
- Reboot and confirm execution.

Acceptance:

```text
/tmp/franklin.log contains "S99franklin-boot start"
```

### Phase 2 — Switch persistence

Put the verified sequence in the boot hook, with a short wait:

```sh
#!/bin/sh
LOG=/tmp/franklin.log
PLOG=/jffs/franklin.log
echo "[$(date)] boot start" >> "$LOG"
echo "[$(date)] boot start" >> "$PLOG"
sleep 8
/bin/ethswctl -c hw-switching -o enable >> "$PLOG" 2>&1
/bin/ethswctl -c softswitch -i eth0 -o enable >> "$PLOG" 2>&1
/bin/ethswctl -c softswitch -i eth1 -o enable >> "$PLOG" 2>&1
echo "[$(date)] switch state: $(/bin/ethswctl -c hw-switching) $(/bin/ethswctl -c softswitch)" >> "$PLOG"
```

Acceptance:

```text
hw-switching = Enabled
softswitch   = 120
```

If the boot hook runs too early, increase `sleep` or wait for the switch tool
to succeed in a loop.

### Phase 3 — Entware (optional)

Entware gives:

- `opkg`
- `cron`
- `lighttpd` / `uhttpd`
- `tcpdump`, `iperf3`, `ethtool`
- `bash`, `coreutils`, `jq`, `python` (with caveats)

Install on the USB partition under `asusware.arm` or a separate `opt`
partition. Use the Entware `armv7sf-k3.2` repo.

Watch out for:

- `LD_LIBRARY_PATH` conflicts with firmware libraries.
- Older glibc expectations.
- Cron scripts calling Entware binaries need `unset LD_LIBRARY_PATH`.

### Phase 4 — Custom control panel

Preferred: a separate web server on another port, e.g. `:8080`.

Minimum actions:

- show `hw-switching` state
- show `softswitch` map
- enable/disable `hw-switching`
- enable/disable `softswitch` on `eth0` / `eth1`
- show bridge and interface status

Implementation options:

1. `lighttpd` + CGI shell scripts.
2. A small static Go binary with an HTTP server.
3. `uhttpd` + Lua/CGI if available.

Do not patch `httpd` unless the goal is specifically to integrate with the
stock UI.

### Phase 5 — Optional page overlay

- Copy `/www` to `/tmp/www`.
- Add or replace ASP pages.
- Update `/tmp/www/require/modules/menuTree.js`.
- Bind-mount `/tmp/www` over `/www`.
- Recreate at boot from the Franklin hook.

Acceptance:

- stock UI still works,
- new page loads,
- existing apply actions still work,
- no backend dependency on missing `apply.cgi` actions.

### Phase 6 — Optional kernel module experiments

Only for generic modules, never board/radio/switch modules.

Procedure:

1. Extract the donor firmware.
2. Locate the module (e.g. `sch_cake.ko`).
3. Compare `vermagic` with the XT9.
4. Load with `insmod`.
5. Check `dmesg` for errors.
6. Unload if anything is wrong.
7. Never persist a module that is not proven.

Board-specific modules and calibration data are out of scope.

---

## 6. What Franklin can and cannot do

### Can do

- boot-time scripts
- cron/watchdogs
- Entware packages
- custom web UI
- diagnostics (`tcpdump`, `iperf3`, `ethtool`)
- call `ethswctl`, `vlanctl`, `brctl`
- overlay web pages and menu entries
- SQM with built-in `fq_codel`/`ifb`
- possibly Cake with a compatible module

### Cannot do (safely)

- become real Merlin/gnuton firmware
- patch `httpd`/`rc`/kernel without risk
- add arbitrary `apply.cgi` actions as files
- port calibration data
- port switch/radio drivers
- guarantee persistence if the USB stick dies

---

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| USB stick failure | Keep a backup stick; use `/jffs` for critical scripts |
| Bad boot script | Test manually first; keep SSH key in ASUS settings; console/reset |
| Switch state wrong | Log both before/after; read `ethswctl` state; keep manual recovery |
| Firmware update overwrites | Re-create `asusware.arm` after update; document |
| Entware glibc conflicts | `unset LD_LIBRARY_PATH` in cron scripts |
| Module mismatch | Test one module at a time; never persist untested |
| Web UI security | LAN-only, auth, no Internet exposure |
| Stock UI breakage | Overlay only pages you need; keep original `/www` copy |

---

## 8. Open questions

1. Does the `asusware.arm` hook run before or after the switch is ready?
   (Observed: after; `sleep 8` was enough for logging.)
2. Can the switch sequence be applied reliably at boot without a sleep or with
   a retry loop?
3. Does `softswitch = 120` survive a warm reboot, or must it be re-applied?
4. Which Entware packages work cleanly under this firmware’s glibc?
5. Is a compatible `sch_cake.ko` available from a donor build with the same
   vermagic?
6. Should Franklin use the stock UI overlay at all, or only a separate `:8080`
   panel?
7. How should Franklin be packaged for other ASUSWRT devices?
   - USB bootstrap folder
   - one-shot installer
   - per-model profile

---

## 9. Project layout (future)

```text
C:\dev\personal\franklin\
├── plans\
│   └── franklin.md
├── scripts\
│   ├── boot\
│   │   └── S99franklin-boot
│   ├── install\
│   │   └── install-franklin.sh
│   └── tools\
│       ├── franklin-ethswctl.sh
│       └── franklin-status.sh
├── usb\
│   └── asusware.arm\
│       ├── .asusrouter
│       ├── etc\init.d\
│       └── lib\ipkg\info\
├── web\
│   ├── lighttpd\
│   └── cgi\
└── docs\
    ├── xt9-notes.md
    └── recovery.md
```

---

## 10. Minimal first version

If we only build one useful thing:

1. `asusware.arm` with `S99franklin-boot`.
2. Boot script applies the verified switch sequence.
3. Logs to `/tmp/franklin.log` and `/jffs/franklin.log`.
4. Verify after reboot:

```text
hw-switching = Enabled
softswitch   = 120
```

That alone solves the real problem and proves the concept.

Everything else — Entware, custom UI, module experiments — is optional.

---

## 11. References / prior art

- Entware on ASUS stock firmware:
  https://github.com/Entware/Entware/wiki/Install-on-ASUS-stock-firmware
- gnuton asuswrt-merlin.ng:
  https://github.com/gnuton/asuswrt-merlin.ng
- asuswrt-scripts (asusware usbmount):
  https://github.com/jacklul/asuswrt-scripts
- `plans/dolguldur-egress-vpn.md` in the homelab repo
- `plans/frankenmerlin-xt9.md` in the homelab repo
- This session’s verified commands and logs.
