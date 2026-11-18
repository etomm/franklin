#!/bin/sh
# Stage the gnuton web UI *delta* into this feature's payload, using the shared
# /opt prefix:
#
#   payload/opt/share/gnuton-www/          only files that are new or differ
#   payload/opt/share/gnuton-www/WHITEOUTS stock pages gnuton dropped
#   payload/opt/bin/gnuton-httpd           gnuton /usr/sbin/httpd
#   payload/opt/lib/gnuton/                libs missing or different in stock
#
# At boot the UI is mounted as overlay(lowerdir=<delta>:/www), so stock pages
# stay reachable as the fallback layer and only the delta is shipped.
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
DELTA="$OUT/opt/share/gnuton-www"
mkdir -p "$OUT/opt/bin" "$OUT/opt/lib/gnuton" "$DELTA"

# 1. httpd (namespaced: does not shadow a stock or Entware `httpd`)
cp "$GNUTON_ROOTFS/usr/sbin/httpd" "$OUT/opt/bin/gnuton-httpd"
chmod 755 "$OUT/opt/bin/gnuton-httpd"

# 2. /www delta: new files + files whose content differs from stock.
copy=0
skip=0
# deliberately not overridden (see note below)
NO_OVERRIDE="ajax_wificlients.asp"
(
    cd "$GNUTON_ROOTFS/www" || exit 1
    find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do
        rel=${f#./}
        case " $NO_OVERRIDE " in
            *" $rel "*) continue ;;
        esac
        dst="$DELTA/$rel"
        stock="$STOCK_ROOTFS/www/$rel"
        if [ -f "$stock" ] && cmp -s "$f" "$stock"; then
            skip=$((skip + 1))
            continue
        fi
        mkdir -p "$(dirname "$dst")"
        cp "$f" "$dst"
        copy=$((copy + 1))
    done
)

# The wireless-log page has two data paths, both answered by httpd ASP
# handlers that gnuton's XT8 build cannot satisfy on this model:
#   * an inline <% get_wl_status(); %> on load (emits malformed JS), and
#   * a /ajax_wificlients.asp poll every 3 s (404 here).
# The wifi-clients job publishes /www/ajax_wificlients.asp with the same
# variables, so the page only needs the inline call removed.
WL_PAGE="$DELTA/Main_WStatus_Content.asp"
if [ -f "$WL_PAGE" ]; then
    sed -i "s|<% get_wl_status(); %>;||" "$WL_PAGE"
    # The details box pulls /wl_log.asp, answered by the same broken handler,
    # and httpd only serves its own whitelisted files without auth. The
    # wifi-clients feed therefore embeds the dump as window.franklinWlText in
    # the polled script; GenContent just fills the textarea from it.
    sed -i 's|function GenContent(){|function GenContent(){ if (window.franklinWlText) { $("#wl_log").text(window.franklinWlText); } return;|' "$WL_PAGE"
    echo "patched wireless-log page (feeds: /ajax_wificlients.asp + embedded wl text)"
fi

# The counters above run in a subshell, so recount for the summary.
delta_files=$(find "$DELTA" -type f | wc -l)

# 3. /www removals: stock pages gnuton does not ship. They become overlayfs
#    whiteouts, so the merged view matches gnuton rather than showing stale
#    ASUS pages next to gnuton ones.
(
    cd "$STOCK_ROOTFS/www" || exit 1
    find . -maxdepth 1 -name '*.asp' -type f -print | LC_ALL=C sort | while IFS= read -r f; do
        rel=${f#./}
        [ -e "$GNUTON_ROOTFS/www/$rel" ] && continue
        echo "$rel"
    done
) >"$DELTA/WHITEOUTS"
whiteouts=$(wc -l <"$DELTA/WHITEOUTS")

# 3. libs that stock does not have (or has a different build of).
#    Skip only the libraries that read *hardware data*: gnuton's XT8 builds of
#    libwlcsm/libbwdpi return nothing useful on the XT9. Do NOT skip libnvram or
#    libshared: gnuton's httpd is ABI-coupled to them (measured: with stock
#    copies /Main_Login.asp renders 0-8 KB or nothing at all, with gnuton's it
#    renders ~22 KB).
SKIP_LIBS="libwlcsm libbwdpi"
# Files we deliberately do NOT override: the gnuton versions of these pages
# call httpd ASP handlers compiled against XT8's sta_info layout, which the XT9
# driver does not match — the served JS is malformed (`,"-42",AU"]`) and the
# page dies with a SyntaxError. Serving stock's version keeps the UI consistent
# until httpd is rebuilt from source for this model.
NO_OVERRIDE="ajax_wificlients.asp"
LIB="$OUT/opt/lib/gnuton"
libs=0
skipped=0
for lib in $(cd "$GNUTON_ROOTFS" && find usr/lib lib -name '*.so*' -type f | sort); do
    src="$GNUTON_ROOTFS/$lib"
    rel=${lib#usr/}
    rel=${rel#lib/}
    base=$(basename "$rel")
    skip=0
    for pat in $SKIP_LIBS; do
        case "$base" in "$pat"*) skip=1 ;; esac
    done
    if [ "$skip" = "1" ]; then
        skipped=$((skipped + 1))
        continue
    fi
    stock="$STOCK_ROOTFS/$lib"
    if [ -f "$stock" ] && cmp -s "$src" "$stock"; then
        continue
    fi
    mkdir -p "$LIB/$(dirname "$rel")"
    cp "$src" "$LIB/$rel"
    libs=$((libs + 1))
done

# 5. reproducible metadata
find "$OUT" -exec touch -d '@0' {} + 2>/dev/null || true
printf 'gnuton httpd + www delta + %d lib(s), %d skipped\n' "$libs" "$skipped" > "$DELTA/SOURCE"
echo "staged $OUT"
echo "  www delta: $delta_files file(s) (stock fallback: the rest), $whiteouts whiteout(s)"
echo "  libs: $libs (skipped $skipped system libs)"
