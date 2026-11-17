#!/bin/sh
# Reproducible kernel-module build for an ASUSWRT device.
#
# Builds selected modules from an ASUS GPL archive against a device config,
# using the bcmkernel include overlay. Run inside WSL/Debian (or any Linux)
# with an ARM cross compiler (default arm-linux-gnueabi-).
#
# Usage:
#   build-kernel-modules.sh \
#     --config device.config \
#     (--gpl GPL_ZENWIFI_XT9_....zip | --kernel /path/to/linux-4.19) \
#     [--workdir /root/xt9-gpl] [--out ./build/kernel-modules] \
#     [--model XT9] [--modules "net/sched/sch_cake.ko net/netfilter/xt_TEE.ko"] \
#     [--enable "NET_SCH_CAKE=m NETFILTER_XT_TARGET_TEE=m IP_SET=m"]
#
# Notes:
#   * `--config` is the device's `zcat /proc/config.gz` (convert to ASCII/LF).
#   * `--gpl` is the ASUS GPL zip (contains a .tgz with asuswrt/.../kernel).
#   * If --kernel is given, extraction is skipped and the tree is used directly.
#   * The script is idempotent: it restores any existing .config in the tree.

set -u
ARCH="${ARCH:-arm}"
CROSS_COMPILE="${CROSS_COMPILE:-arm-linux-gnueabi-}"
MODEL="${MODEL:-XT9}"
CONFIG=""; GPL=""; KERNEL=""; WORKDIR="/root/franklin-kmod"; OUT="./build/kernel-modules"
MODULES=""; ENABLE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --gpl) GPL="$2"; shift 2;;
    --kernel) KERNEL="$2"; shift 2;;
    --workdir) WORKDIR="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --modules) MODULES="$2"; shift 2;;
    --enable) ENABLE="$2"; shift 2;;
    -h|--help) sed -n '2,30p' "$0"; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

[ -n "$CONFIG" ] || { echo "missing --config" >&2; exit 2; }
[ -r "$CONFIG" ] || { echo "cannot read config: $CONFIG" >&2; exit 2; }

mkdir -p "$WORKDIR"
if [ -z "$KERNEL" ]; then
  [ -n "$GPL" ] || { echo "need --gpl or --kernel" >&2; exit 2; }
  TGZ="$WORKDIR/gpl.tgz"
  if [ ! -f "$TGZ" ]; then
    echo "extracting $GPL -> $TGZ"
    unzip -p "$GPL" > "$TGZ" || exit 1
  fi
  SRC=$(tar tzf "$TGZ" | head -1 | cut -d/ -f1)
  BASE=$(tar tzf "$TGZ" | grep -m1 'src-rt-5.04.*/kernel/linux-4.19/Makefile$' | sed 's#/kernel/linux-4.19/Makefile##')
  [ -n "$BASE" ] || { echo "cannot locate kernel tree in GPL" >&2; exit 1; }
  echo "kernel tree: $BASE/kernel/linux-4.19"
  tar xzf "$TGZ" -C "$WORKDIR" "$BASE/kernel/linux-4.19/" "$BASE/kernel/bcmkernel/" "$BASE/bcmdrivers/" 2>/dev/null || true
  KERNEL="$WORKDIR/$BASE/kernel/linux-4.19"
  BCMK="$WORKDIR/$BASE/kernel/bcmkernel"
else
  BCMK=$(dirname "$KERNEL")/bcmkernel
fi

[ -d "$KERNEL" ] || { echo "missing kernel tree: $KERNEL" >&2; exit 1; }
[ -d "$BCMK" ] || { echo "missing bcmkernel overlay: $BCMK" >&2; exit 1; }

cd "$KERNEL" || exit 1
SAVED=""
if [ -f .config ]; then cp .config .config.franklin.bak; SAVED=1; fi
cp "$CONFIG" .config
# GPL gaps that block olddefconfig
sed -i 's|^source "net/netfilter/fltr/Kconfig"|# source fltr/Kconfig removed (GPL excluded)|' net/netfilter/Kconfig 2>/dev/null || true
sed -i 's|^source "../../bcmdrivers/Kconfig.autogen"|# source bcmdrivers/Kconfig.autogen removed (GPL excluded)|' Kconfig.bcm 2>/dev/null || true
# enable requested symbols
for kv in $ENABLE; do
  sym=${kv%%=*}
  scripts/config --module "$sym" >/dev/null 2>&1 || true
done
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" MODEL="$MODEL" olddefconfig >/tmp/franklin-olddef.log 2>&1 || {
  echo "olddefconfig failed (see /tmp/franklin-olddef.log)" >&2; [ -n "$SAVED" ] && mv .config.franklin.bak .config; exit 1; }
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" MODEL="$MODEL" WERROR=0 \
  KCFLAGS="-I$BCMK/include -I$BCMK/include/uapi" modules_prepare >/tmp/franklin-prep.log 2>&1 || {
  echo "modules_prepare failed (see /tmp/franklin-prep.log)" >&2; [ -n "$SAVED" ] && mv .config.franklin.bak .config; exit 1; }
if [ -z "$MODULES" ]; then
  MODULES="net/sched/sch_cake.ko net/netfilter/xt_TEE.ko net/netfilter/ipset/ip_set.ko net/netfilter/ipset/ip_set_hash_ip.ko"
fi
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" MODEL="$MODEL" WERROR=0 \
  KCFLAGS="-I$BCMK/include -I$BCMK/include/uapi" $MODULES >/tmp/franklin-modbuild.log 2>&1 || {
  echo "module build failed (see /tmp/franklin-modbuild.log)" >&2; tail -20 /tmp/franklin-modbuild.log >&2; [ -n "$SAVED" ] && mv .config.franklin.bak .config; exit 1; }

mkdir -p "$OUT"
for m in $MODULES; do
  [ -f "$m" ] && cp "$m" "$OUT/" && echo "built: $OUT/$(basename "$m")"
done
[ -n "$SAVED" ] && mv .config.franklin.bak .config
echo "done. artifacts in $OUT"
