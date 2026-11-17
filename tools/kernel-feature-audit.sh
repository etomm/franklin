#!/bin/sh
# kernel-feature-audit.sh
#
# Classify kernel features for a stock ASUSWRT device against a kernel source
# tree (e.g. ASUS GPL or gnuton), producing a reusable matrix:
#   - present (built-in =y)
#   - present (module =m)
#   - modularizable  (absent on stock, but tristate -> can build a .ko)
#   - built-in only  (absent, bool/forced -> needs a kernel rebuild/flash)
#   - unavailable    (absent, deps unmet or symbol unknown)
#
# Usage:
#   kernel-feature-audit.sh \
#     --config  /path/to/device.config \
#     --kernel  /path/to/asus/gpl/.../kernel/linux-4.19 \
#     --features /path/to/tools/kernel-features.txt \
#     [--out matrix.md]
#
# Notes:
#   * The device config is normally `zcat /proc/config.gz` (convert UTF-16 to
#     ASCII if copied via PowerShell).
#   * The kernel tree must be a matching source tree (same version as the
#     device) for the modularizable/built-in classification to be meaningful.
#     The script is idempotent and restores the tree's .config afterwards.
#   * Requires: make, scripts/config in the kernel tree, cross compiler
#     (CROSS_COMPILE, default arm-linux-gnueabi-), ARCH (default arm).

set -u

CONFIG=""
KERNEL=""
FEATURES=""
OUT=""
ARCH="${ARCH:-arm}"
CROSS_COMPILE="${CROSS_COMPILE:-arm-linux-gnueabi-}"
MODEL="${MODEL:-XT9}"

while [ $# -gt 0 ]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --kernel) KERNEL="$2"; shift 2;;
    --features) FEATURES="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    -h|--help) sed -n '2,30p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$CONFIG" ] || { echo "missing --config" >&2; exit 2; }
[ -r "$CONFIG" ] || { echo "cannot read config: $CONFIG" >&2; exit 2; }
[ -n "$FEATURES" ] || { echo "missing --features" >&2; exit 2; }
[ -r "$FEATURES" ] || { echo "cannot read features: $FEATURES" >&2; exit 2; }

# --- helpers ---------------------------------------------------------------
cfg_val() {
  if grep -q "^CONFIG_$1=" "$CONFIG"; then
    grep "^CONFIG_$1=" "$CONFIG" | head -1 | sed 's/^[^=]*=//'
  elif grep -q "^# CONFIG_$1 is not set" "$CONFIG"; then
    echo "n"
  else
    echo ""
  fi
}

# --- parse features --------------------------------------------------------
TMP=$(mktemp)
trap 'rm -f "$TMP" "$TMP.absent" "$TMP.results"' EXIT
grep -v '^[[:space:]]*#' "$FEATURES" | grep '|' > "$TMP"

ABSENT_SYMS="$TMP.absent"
: > "$ABSENT_SYMS"
while IFS='|' read -r sym desc; do
  [ -n "$sym" ] || continue
  v=$(cfg_val "$sym")
  case "$v" in
    y|m) : ;;
    *) echo "$sym" >> "$ABSENT_SYMS" ;;
  esac
done < "$TMP"

# --- classify absent symbols using the kernel tree -------------------------
RESULTS="$TMP.results"
: > "$RESULTS"

if [ -n "$KERNEL" ] && [ -d "$KERNEL" ] && [ -s "$ABSENT_SYMS" ]; then
  OLD_PWD=$(pwd)
  cd "$KERNEL" || exit 1
  SAVED=""
  if [ -f .config ]; then
    cp .config .config.audit.bak
    SAVED=1
  fi
  cp "$CONFIG" .config
  sed -i 's|^source "net/netfilter/fltr/Kconfig"|# source fltr/Kconfig removed (GPL excluded)|' net/netfilter/Kconfig 2>/dev/null || true
  sed -i 's|^source "../../bcmdrivers/Kconfig.autogen"|# source bcmdrivers/Kconfig.autogen removed (GPL excluded)|' Kconfig.bcm 2>/dev/null || true
  while read -r sym; do
    [ -n "$sym" ] || continue
    scripts/config --module "$sym" >/dev/null 2>&1 || true
  done < "$ABSENT_SYMS"
  make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" MODEL="$MODEL" olddefconfig >/dev/null 2>&1 || true
  while read -r sym; do
    [ -n "$sym" ] || continue
    if grep -q "^CONFIG_$sym=m" .config; then
      echo "$sym=modularizable" >> "$RESULTS"
    elif grep -q "^CONFIG_$sym=y" .config; then
      echo "$sym=builtinonly" >> "$RESULTS"
    else
      echo "$sym=unavailable" >> "$RESULTS"
    fi
  done < "$ABSENT_SYMS"
  if [ -n "$SAVED" ]; then mv .config.audit.bak .config; fi
  cd "$OLD_PWD" || exit 1
fi

res_for() {
  grep "^$1=" "$RESULTS" 2>/dev/null | head -1 | sed 's/^[^=]*=//'
}

# --- emit matrix -----------------------------------------------------------
emit() {
  echo "| Feature | Config symbol | Stock state | Classification |"
  echo "|---|---|---|---|"
  while IFS='|' read -r sym desc; do
    [ -n "$sym" ] || continue
    v=$(cfg_val "$sym")
    case "$v" in
      y) state="y (built-in)"; cls="present (built-in)";;
      m) state="m (module)";    cls="present (module)";;
      n) state="not set";       cls="$(res_for "$sym")";;
      *) state="absent";        cls="$(res_for "$sym")";;
    esac
    case "$cls" in
      "") cls="not checked (no kernel tree)";;
      modularizable) cls="MODULARIZABLE (build .ko)";;
      builtinonly) cls="BUILT-IN ONLY (needs kernel rebuild)";;
      unavailable) cls="unavailable (bool off / deps unmet)";;
    esac
    printf '| %s | `%s` | %s | %s |\n' "$desc" "$sym" "$state" "$cls"
  done < "$TMP"
}

if [ -n "$OUT" ]; then
  {
    echo "# Kernel / feature matrix for ASUSWRT (stock vs gnuton)"
    echo
    echo "Generated from: \`$CONFIG\`"
    [ -n "$KERNEL" ] && echo "Kernel tree: \`$KERNEL\`"
    echo
    echo "Classification:"
    echo "- **present (built-in/module)** - already on the stock device."
    echo "- **MODULARIZABLE** - absent on stock, but Kconfig allows it as a"
    echo "  module; build the .ko from the matching ASUS GPL tree and"
    echo "  insmod (must be built from the matching ASUS tree, not vanilla)."
    echo "- **BUILT-IN ONLY** - bool/forced; would need a kernel rebuild/flash."
    echo "- **unavailable** - symbol unknown or dependencies unmet."
    echo
    echo "> Caveat: MODULARIZABLE only means the symbol can be built as a"
    echo "> module. It must still be built from the matching ASUS GPL tree with"
    echo "> the device .config and tested (insmod + functional test)."
    echo
    echo "## Kernel config features"
    echo
    emit
    echo
    echo "## Userland features (not kernel config)"
    echo
    echo "These are implemented in userland (rc / iptables / dnsmasq / daemons)."
    echo "Franklin can reproduce most with scripts or gnuton binaries; swapping"
    echo "rc itself is not required."
    echo
    echo "| Feature | Where gnuton implements it | Franklin approach |"
    echo "|---|---|---|"
    echo "| VPN killswitch | rc + iptables/ip rules | reimplement rules in boot hook |"
    echo "| VPN Director / OpenVPN routing | rc + ip rules + helper daemon | scripts/ip rules or gnuton helper |"
    echo "| DNS Director / DNSFilter | iptables REDIRECT + dnsmasq | iptables + dnsmasq config |"
    echo "| NTP interception | iptables | iptables rule |"
    echo "| Guest Network fixes | rc + bridge config | hostapd/bridge config |"
    echo "| Adaptive QoS / DPI | bwdpi daemon + BCM_DPI module | BCM_DPI .ko + userspace (see kernel table) |"
    echo "| Cake QoS | sch_cake.ko | build/load sch_cake.ko (verified) |"
    echo "| ipset / Skynet | ip_set.ko + ipset tool | build/load ip_set.ko + gnuton ipset |"
    echo "| TEE / packet duplication | xt_TEE.ko + nf_dup | build/load modules (verified) |"
    echo "| Web UI | httpd + /www | run gnuton httpd + www on :8088 (verified) |"
    echo "| Traffic Monitor / Sysinfo | httpd + /www | gnuton UI (verified) |"
    echo "| NVRAM / JFFS layout | bootloader/flash | not changeable at runtime |"
    echo "| NAT acceleration (CTF/FA) | driver/kernel built-in | not modularizable |"
    echo "| Wireless driver internals | dhd/wl modules + radio fw | model-specific, not portable |"
  } > "$OUT"
  echo "wrote $OUT"
  emit
else
  emit
fi
