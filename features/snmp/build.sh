#!/bin/sh
# Stage the gnuton SNMP agent and the net-snmp libraries it links against.
#
# Input:   firmware/gnuton-xt8/rootfs (extracted gnuton firmware)
# Output:  features/snmp/payload/opt/sbin/snmpd
#          features/snmp/payload/opt/lib/gnuton/libnetsnmp*.so.35.0.0
#
# Only real files are copied: gnuton ships the .so.35 names as symlinks, and
# symlinks do not survive the Windows-side composition. start.sh recreates the
# SONAME links on the stick, where writing them is cheap and idempotent.
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
GNUTON_ROOTFS="${GNUTON_ROOTFS:-$ROOT/firmware/gnuton-xt8/rootfs}"
OUT="${OUT:-$ROOT/features/snmp/payload}"

SRC_BIN="$GNUTON_ROOTFS/usr/sbin/snmpd"
[ -f "$SRC_BIN" ] || {
    echo "missing $SRC_BIN (extract the gnuton firmware first)" >&2
    exit 1
}

# Only the generated binaries are replaced: payload/ also carries the
# feature scripts, which must survive a rebuild.
rm -rf "$OUT/opt"
mkdir -p "$OUT/opt/sbin" "$OUT/opt/lib/gnuton"

cp "$SRC_BIN" "$OUT/opt/sbin/snmpd"

libs=0
for lib in libnetsnmp libnetsnmpagent libnetsnmphelpers libnetsnmpmibs; do
    src="$GNUTON_ROOTFS/usr/lib/$lib.so.35.0.0"
    [ -f "$src" ] || {
        echo "missing $src" >&2
        exit 1
    }
    cp "$src" "$OUT/opt/lib/gnuton/$lib.so.35.0.0"
    libs=$((libs + 1))
done

find "$OUT" -exec touch -d '@0' {} + 2>/dev/null || true

# Same freshness stamp as features/web-ui/build.sh; see build_stamp() in
# tools/franklin-compose.py. Payloads are gitignored, so without it a stale
# binary set would be composed silently.
here=$(cd "$(dirname "$0")" && pwd)
stamp=$( {
    printf '%s\0' build.sh;    cat "$here/build.sh";    printf '\0'
    printf '%s\0' feature.yaml; cat "$here/feature.yaml"; printf '\0'
} | sha256sum | cut -d' ' -f1 )
printf '%s\n' "$stamp" > "$OUT/.build-stamp"

echo "staged $OUT (snmpd + $libs netsnmp libraries)"
