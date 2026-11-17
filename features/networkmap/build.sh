#!/bin/sh
# Stage gnuton's networkmap binary into payload/opt/sbin/gnuton-networkmap.
# Input: GNUTON_ROOTFS (default firmware/gnuton-xt8/rootfs).
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
GNUTON_ROOTFS="${GNUTON_ROOTFS:-$ROOT/firmware/gnuton-xt8/rootfs}"
OUT="${OUT:-$ROOT/features/networkmap/payload}"

[ -x "$GNUTON_ROOTFS/usr/sbin/networkmap" ] || {
    echo "missing $GNUTON_ROOTFS/usr/sbin/networkmap" >&2
    exit 1
}
mkdir -p "$OUT/opt/sbin"
cp "$GNUTON_ROOTFS/usr/sbin/networkmap" "$OUT/opt/sbin/gnuton-networkmap"
chmod 755 "$OUT/opt/sbin/gnuton-networkmap"
touch -d '@0' "$OUT/opt/sbin/gnuton-networkmap" 2>/dev/null || true
echo "staged $OUT/opt/sbin/gnuton-networkmap ($(wc -c <"$OUT/opt/sbin/gnuton-networkmap") bytes)"
