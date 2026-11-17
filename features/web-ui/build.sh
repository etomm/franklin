#!/bin/sh
# Stage gnuton's web UI into this feature's payload/, using the shared /opt
# prefix (merged with the other features) but namespaced where collisions with
# Entware are likely:
#
#   payload/opt/bin/gnuton-httpd       gnuton /usr/sbin/httpd
#   payload/opt/share/gnuton-www/      gnuton /www tree
#   payload/opt/lib/gnuton/            every lib missing or different in stock
#
# Which becomes /opt/bin/gnuton-httpd, /opt/share/gnuton-www, /opt/lib/gnuton
# on the device, because /tmp/opt points at franklin/opt.
#
# Inputs (both extracted per docs/firmware-comparison.md):
#   STOCK_ROOTFS   firmware/xt8/rootfs
#   GNUTON_ROOTFS  firmware/gnuton-xt8/rootfs
#
# Determinism: files copied in sorted order, mtimes set to 0.
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
STOCK_ROOTFS="${STOCK_ROOTFS:-$ROOT/firmware/xt8/rootfs}"
GNUTON_ROOTFS="${GNUTON_ROOTFS:-$ROOT/firmware/gnuton-xt8/rootfs}"
OUT="${OUT:-$ROOT/features/web-ui/payload}"

[ -x "$GNUTON_ROOTFS/usr/sbin/httpd" ] || {
    echo "missing $GNUTON_ROOTFS/usr/sbin/httpd (extract the gnuton firmware first)" >&2
    exit 1
}
[ -d "$GNUTON_ROOTFS/www" ] || {
    echo "missing $GNUTON_ROOTFS/www" >&2
    exit 1
}

rm -rf "$OUT"
mkdir -p "$OUT/opt/bin" "$OUT/opt/lib/gnuton" "$OUT/opt/share"

# 1. httpd (namespaced: stock has its own /opt/bin/httpd once Entware exists)
cp "$GNUTON_ROOTFS/usr/sbin/httpd" "$OUT/opt/bin/gnuton-httpd"
chmod 755 "$OUT/opt/bin/gnuton-httpd"

# 2. /www tree
# The extracted rootfs can contain dangling symlinks (extraction artefacts), so
# copy regular files and resolve symlinks, skipping broken ones.
WWW="$OUT/opt/share/gnuton-www"
mkdir -p "$WWW"
(
    cd "$GNUTON_ROOTFS/www" || exit 1
    find . -type d -exec mkdir -p "$WWW/{}" \;
    find . \( -type f -o -type l \) -print | while IFS= read -r f; do
        if [ -f "$f" ]; then
            cp "$f" "$WWW/$f"
        else
            echo "  skipping broken link: www/${f#./}" >&2
        fi
    done
)

# 3. libs that stock does not have (or has a different build of)
LIB="$OUT/opt/lib/gnuton"
count=0
for lib in $(cd "$GNUTON_ROOTFS" && find usr/lib lib -name '*.so*' -type f | sort); do
    src="$GNUTON_ROOTFS/$lib"
    rel=${lib#usr/}
    rel=${rel#lib/}
    stock="$STOCK_ROOTFS/$lib"
    if [ -f "$stock" ] && cmp -s "$src" "$stock"; then
        continue
    fi
    mkdir -p "$LIB/$(dirname "$rel")"
    cp "$src" "$LIB/$rel"
    count=$((count + 1))
done

# 4. reproducible metadata
find "$OUT" -exec touch -d '@0' {} + 2>/dev/null || true
printf 'gnuton httpd + www + %d differing lib(s)\n' "$count" > "$OUT/opt/share/gnuton-www/SOURCE"
echo "staged $OUT ($count libs)"
