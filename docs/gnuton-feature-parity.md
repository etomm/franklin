# gnuton feature parity

Franklin cannot become gnuton firmware, but it can port **userland** features.
Track status here. "Ported" means adapted into Franklin's userland layer.

| gnuton feature | Franklin status | Notes |
|---|---|---|
| Boot-time scripts | Ported (core/boot) | asusware.arm hook |
| Entware / opkg | Planned | armv7sf-k3.2 |
| cron / watchdog | Planned | Entware or shell loop |
| Custom web UI (:8080) | Planned | lighttpd + CGI |
| Diagnostics (tcpdump, iperf3, ethtool) | Planned | via Entware |
| VLAN / ethswctl helpers | Ported (core/tools) | XT9 verified sequence |
| Bridge / brctl helpers | Planned | |
| SQM (fq_codel/ifb) | Research | kernel has IFB + fq_codel |
| Cake qdisc | Research | needs compatible sch_cake.ko |
| Web UI overlay (/www) | Planned | bind mount, no httpd patch |
| Adaptive QoS / classification | Not planned | firmware-level |
| VPN (OpenVPN/WireGuard) | Not planned | firmware-level; use Entware |
| AiMesh | Not applicable | stock firmware handles |
| Kernel/driver features | Out of scope | never port board-specific modules |

## How to port a feature
1. Check GNUTON_REF pinned commit; fetch upstream with tools/fetch-gnuton.sh (WSL).
2. Locate the relevant file(s) in vendor/gnuton.
3. Copy + adapt into Franklin, recording the source path + commit in a header comment.
4. Add a row above and update status.
5. Test on device; keep recovery path.
