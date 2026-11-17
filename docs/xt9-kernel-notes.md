# XT9 kernel notes (module build feasibility)

Device: ASUS ZenWiFi XT9 (productid `XT8PRO`, model `ZenWiFi_XT8P`),
firmware `3.0.0.4.388_24854-g9c246e8`.

## Kernel identity
```
Linux 4.19.183 (root@asus) (gcc 9.2.0, Buildroot 2019.11.1) #1 SMP PREEMPT
vermagic = 4.19.183 SMP preempt mod_unload ARMv7 p2v8
/lib/modules/4.19.183 : 128 .ko, 327 built-in
```

## Config — verified from `/proc/config.gz` (3941 lines)
| Feature | Config | State |
|---|---|---|
| fq_codel | `CONFIG_NET_SCH_FQ_CODEL` | `=y` (built-in) |
| IFB | `CONFIG_IFB` | `=y` |
| TC actions | `NET_CLS_ACT`, `ACT_MIRRED`, `ACT_GACT`, `ACT_POLICE` | `=y` |
| NAT / conntrack | `CONFIG_NF_NAT`, `CONFIG_NF_CONNTRACK` | `=y` |
| WireGuard | `CONFIG_WIREGUARD` | `=m` (`wireguard.ko` present) |
| Cake | `CONFIG_NET_SCH_CAKE` | **not set** |
| netfilter TEE | `CONFIG_NETFILTER_XT_TARGET_TEE` | **not set** |
| ipset | `CONFIG_IP_SET` | **not set** |

Module-loading-relevant:
```
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_ARM_MODULE_PLTS=y
# CONFIG_MODVERSIONS is not set    -> no CRC matching
# CONFIG_MODULE_SIG is not set     -> unsigned modules allowed
# CONFIG_MODULE_FORCE_LOAD is not set
CONFIG_LOCALVERSION=""
```

## What this means
- Anything `=y` is already available (fq_codel/IFB/TC → SQM works today).
- Cake, TEE, ipset are **absent** (neither built-in nor module) → would need a
  module compiled for **4.19.183**.
- Because `MODVERSIONS` and `MODULE_SIG` are off, a module only needs the
  **matching vermagic** and ABI. That is realistic.

## Module build recipe (target: `sch_cake.ko`, `xt_TEE.ko`, `ip_set*.ko`)
1. **Kernel source 4.19.183**
   - ASUS GPL: XT9 support page → select OS **"Other"** → *Source Code*
     (or `https://www.asus.com/support/gpl/`). This is the exact tree.
   - gnuton repo also carries HND trees, e.g.
     `release/src-rt-5.04axhnd.675x` (BCM675x, 4.19) and the 3006/BCM4912 tree.
   - Vanilla `linux-4.19.183` from kernel.org works for standard modules if the
     ASUS patches don't change the used ABI/symbols (verify by loading).
2. **Config**: `zcat /proc/config.gz > .config` from the device.
3. **Toolchain**: the kernel used **Buildroot GCC 9.2.0**. Use that (gnuton's
   build Docker provides it) or a compatible `arm-linux-gnueabi` GCC 9.x.
   Cross-compile: `ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-`.
4. **Build**: `make olddefconfig modules_prepare`, then
   `make M=net/sched` (or the relevant dir) / build the in-tree module.
5. **Verify vermagic**:
   `arm-linux-gnueabi-strings sch_cake.ko | grep vermagic`
   must read `4.19.183 SMP preempt mod_unload ARMv7 p2v8`.
6. **Test on device (not persistent until proven)**:
   `insmod /tmp/sch_cake.ko`; check `dmesg`; `tc qdisc add dev br0 root cake`.
   `rmmod` to roll back. Only persist via a boot hook after verification.

## Experimental result (vanilla 4.19.183 build)

Built from **vanilla** `linux-4.19.183` + the XT9's `/proc/config.gz`, cross-compiled
with `arm-linux-gnueabi-gcc`:

| Module | Build | Loads (`insmod`) | Usable |
|---|---|---|---|
| `sch_cake.ko` | ✅ | ✅ (lsmod shows it) | ❌ crashed kernel on `tc qdisc add ... cake` → router rebooted |
| `xt_TEE.ko` | ✅ | not reached | — |
| `ip_set.ko` / `ip_set_hash_ip.ko` | ✅ | not reached | — |

Vermagic matched exactly: `4.19.183 SMP preempt mod_unload ARMv7 p2v8`.

**Conclusion:** a vanilla-built module **loads** (vermagic + no MODVERSIONS/SIG
makes that possible) but is **not runtime-safe** — using Cake caused a kernel
crash/reboot, because the ASUS/Broadcom kernel patches change struct layouts /
APIs relative to vanilla.

Therefore, to get modules that actually work you must build against the **exact
ASUS GPL 4.19.183 tree** for the XT9 (not vanilla), with the device config and
the Buildroot GCC 9.2.0 toolchain. Vanilla is fine for proving loadability, not
for production use.

The test rebooted the router (recovered cleanly; stock UI back up). Modules were
run from `/tmp` and not persisted, so nothing survived the reboot.

## Risks
- ASUS/Broadcom kernel patches could change struct layouts used by a module
  (especially driver-adjacent modules). Standard networking modules
  (sch_cake, xt_TEE, ip_set) are lower risk.
- If a symbol isn't exported, the module won't link; only a kernel rebuild
  (flash) would solve that.
- Kernel is `PREEMPT` and `ARMv7 p2v8`; use matching compiler flags.

## NVRAM (for completeness)
- Backed by files under `/jffs/nvram/` (one file per variable), ~95 KB of
  content. Capacity is bounded by JFFS space, not a fixed partition.
- Contents can be changed at runtime; layout/size cannot (and need not) be.
