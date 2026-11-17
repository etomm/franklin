# Kernel / feature matrix for ASUSWRT (stock vs gnuton)

Generated from: `/root/kbuild/xt9.config`
Kernel tree: `/root/xt9-gpl/asuswrt/release/src-rt-5.04axhnd.675x/kernel/linux-4.19`

Classification:
- **present (built-in/module)** - already on the stock device.
- **MODULARIZABLE** - absent on stock, but Kconfig allows it as a
  module; build the .ko from the matching ASUS GPL tree and
  insmod (must be built from the matching ASUS tree, not vanilla).
- **BUILT-IN ONLY** - bool/forced; would need a kernel rebuild/flash.
- **unavailable** - symbol unknown or dependencies unmet.

> Caveat: MODULARIZABLE only means the symbol can be built as a
> module. It must still be built from the matching ASUS GPL tree with
> the device .config and tested (insmod + functional test).

## Kernel config features

| Feature | Config symbol | Stock state | Classification |
|---|---|---|---|
| Cake QoS qdisc | `NET_SCH_CAKE` | not set | MODULARIZABLE (build .ko) |
| fq_codel qdisc | `NET_SCH_FQ_CODEL` | y (built-in) | present (built-in) |
| fq qdisc | `NET_SCH_FQ` | not set | MODULARIZABLE (build .ko) |
| HTB qdisc | `NET_SCH_HTB` | y (built-in) | present (built-in) |
| TBF qdisc | `NET_SCH_TBF` | y (built-in) | present (built-in) |
| SFQ qdisc | `NET_SCH_SFQ` | y (built-in) | present (built-in) |
| Intermediate Functional Block (SQM) | `IFB` | y (built-in) | present (built-in) |
| Traffic-control actions | `NET_CLS_ACT` | y (built-in) | present (built-in) |
| TC mirred action | `NET_ACT_MIRRED` | y (built-in) | present (built-in) |
| TC police action | `NET_ACT_POLICE` | y (built-in) | present (built-in) |
| TC gact action | `NET_ACT_GACT` | y (built-in) | present (built-in) |
| fw classifier | `NET_CLS_FW` | y (built-in) | present (built-in) |
| u32 classifier | `NET_CLS_U32` | y (built-in) | present (built-in) |
| Extended match | `NET_EMATCH` | not set | unavailable (bool off / deps unmet) |
| WireGuard | `WIREGUARD` | m (module) | present (module) |
| Netfilter NAT | `NF_NAT` | y (built-in) | present (built-in) |
| Netfilter conntrack | `NF_CONNTRACK` | y (built-in) | present (built-in) |
| TEE target (packet duplication) | `NETFILTER_XT_TARGET_TEE` | not set | MODULARIZABLE (build .ko) |
| nf_dup IPv4 (TEE dependency) | `NF_DUP_IPV4` | not set | MODULARIZABLE (build .ko) |
| nf_dup IPv6 (TEE dependency) | `NF_DUP_IPV6` | not set | MODULARIZABLE (build .ko) |
| ipset core | `IP_SET` | not set | MODULARIZABLE (build .ko) |
| ipset hash:ip | `IP_SET_HASH_IP` | absent | MODULARIZABLE (build .ko) |
| ipset hash:net | `IP_SET_HASH_NET` | absent | MODULARIZABLE (build .ko) |
| Broadcom DPI engine | `BCM_DPI` | not set | MODULARIZABLE (build .ko) |
| Broadcom ingress QoS | `BCM_INGQOS` | m (module) | present (module) |
| Broadcom skb extension (struct layout) | `BCM_KF_SKB_EXT` | y (built-in) | present (built-in) |
| Broadcom netdev extension | `BCM_KF_NETDEV_EXT` | y (built-in) | present (built-in) |
| Broadcom netfilter framework | `BCM_KF_NETFILTER` | y (built-in) | present (built-in) |
| Broadcom blog | `BCM_KF_BLOG` | y (built-in) | present (built-in) |
| Broadcom nbuf | `BCM_KF_NBUFF` | y (built-in) | present (built-in) |

## Userland features (not kernel config)

These are implemented in userland (rc / iptables / dnsmasq / daemons).
Franklin can reproduce most with scripts or gnuton binaries; swapping
rc itself is not required.

| Feature | Where gnuton implements it | Franklin approach |
|---|---|---|
| VPN killswitch | rc + iptables/ip rules | reimplement rules in boot hook |
| VPN Director / OpenVPN routing | rc + ip rules + helper daemon | scripts/ip rules or gnuton helper |
| DNS Director / DNSFilter | iptables REDIRECT + dnsmasq | iptables + dnsmasq config |
| NTP interception | iptables | iptables rule |
| Guest Network fixes | rc + bridge config | hostapd/bridge config |
| Adaptive QoS / DPI | bwdpi daemon + BCM_DPI module | BCM_DPI .ko + userspace (see kernel table) |
| Cake QoS | sch_cake.ko | build/load sch_cake.ko (verified) |
| ipset / Skynet | ip_set.ko + ipset tool | build/load ip_set.ko + gnuton ipset |
| TEE / packet duplication | xt_TEE.ko + nf_dup | build/load modules (verified) |
| Web UI | httpd + /www | run gnuton httpd + www on :8088 (verified) |
| Traffic Monitor / Sysinfo | httpd + /www | gnuton UI (verified) |
| NVRAM / JFFS layout | bootloader/flash | not changeable at runtime |
| NAT acceleration (CTF/FA) | driver/kernel built-in | not modularizable |
| Wireless driver internals | dhd/wl modules + radio fw | model-specific, not portable |
