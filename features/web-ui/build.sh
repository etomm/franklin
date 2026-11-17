#!/bin/sh
# Stage gnuton's web UI into this feature's payload/ folder.
#
# The folder layout *is* the layout on the stick:
#   payload/httpd      gnuton /usr/sbin/httpd
#   payload/www/       gnuton /www tree
#   payload/lib/       every lib that is missing or different in stock
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
mkdir -p "$OUT/lib"

# 1. httpd
cp "$GNUTON_ROOTFS/usr/sbin/httpd" "$OUT/httpd"
chmod 755 "$OUT/httpd"

# 2. /www tree
# The extracted rootfs can contain dangling symlinks (extraction artefacts), so
# copy regular files and resolve symlinks, skipping broken ones.
mkdir -p "$OUT/www"
(
    cd "$GNUTON_ROOTFS/www" || exit 1
    find . -type d -exec mkdir -p "$OUT/www/{}" \;
    find . \( -type f -o -type l \) -print | while IFS= read -r f; do
        if [ -f "$f" ]; then
            cp "$f" "$OUT/www/$f"
        else
            echo "  skipping broken link: www/${f#./}" >&2
        fi
    done
)

# 3. libs that stock does not have (or has a different build of)
count=0
for lib in $(cd "$GNUTON_ROOTFS" && find usr/lib lib -name '*.so*' -type f | sort); do
    src="$GNUTON_ROOTFS/$lib"
    rel=${lib#usr/}
    rel=${rel#lib/}
    stock="$STOCK_ROOTFS/$lib"
    if [ -f "$stock" ] && cmp -s "$src" "$stock"; then
        continue
    fi
    mkdir -p "$OUT/lib/$(dirname "$rel")"
    cp "$src" "$OUT/lib/$rel"
    count=$((count + 1))
done

# 4. reproducible metadata
find "$OUT" -exec touch -d '@0' {} + 2>/dev/null || true
printf 'gnuton httpd + www + %d differing lib(s)\n' "$count" > "$OUT/SOURCE"
echo "staged $OUT ($count libs)"
