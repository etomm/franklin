#!/bin/sh
# lib-audit.sh - decide whether a library needs to be shipped from gnuton or
# whether stock's copy is good enough.
#
#   sh tools/lib-audit.sh libwebapi          # one library
#   sh tools/lib-audit.sh --all              # every lib gnuton ships
#
# The rule this implements (from the libwebapi case):
#
#   1. stock does not have the library            -> ship gnuton (no choice)
#   2. gnuton exports a symbol stock does not     -> ship gnuton (an importer
#                                                    may need it)
#   3. export sets are equal                      -> keep stock (preferred)
#   4. ... and every exported function disassembles
#      to the same code                           -> keep stock, confidently
#
# Code-level differences alone do NOT justify shipping gnuton's build: the two
# firmwares compile the same sources with different flags, so instructions
# differ while behaviour does not. They are reported as a signal, not a verdict.
#
# Identical code of the *exported* functions is the strongest statement we can
# make: the interesting logic often lives in a prebuilt object (`priv_*.o`),
# which is identical in both firmwares and cannot be rebuilt anyway.
#
# Runs in WSL/Debian (needs nm, readelf, arm-linux-gnueabi-objdump).
set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
STOCK="${STOCK_ROOTFS:-$ROOT/firmware/xt8/rootfs}"
GNUTON="${GNUTON_ROOTFS:-$ROOT/firmware/gnuton-xt8/rootfs}"
OBJDUMP="${OBJDUMP:-arm-linux-gnueabi-objdump}"

command -v "$OBJDUMP" >/dev/null 2>&1 || {
    echo "missing $OBJDUMP (install binutils-arm-linux-gnueabi)" >&2
    exit 1
}

find_lib() {  # find_lib <rootfs> <name>
    for d in lib usr/lib; do
        for f in "$1/$d/$2" "$1/$d/$2".*; do
            [ -f "$f" ] && { echo "$f"; return 0; }
        done
    done
    return 1
}

exports() { nm -D --defined-only "$1" 2>/dev/null | awk '{print $3}' | sort -u; }

norm_disasm() {  # norm_disasm <lib> <symbol>
    "$OBJDUMP" -d "$1" --disassemble="$2" 2>/dev/null \
        | sed -n "/<$2/,/^\$/p" \
        | sed -E 's/^[[:space:]]*[0-9a-f]+://; s/[0-9a-f]{8}//g; s/\+0x[0-9a-f]+//g; s/[[:space:]]+/ /g' \
        | sed -E 's/[[:space:]][0-9a-f]+ </ </g; s/[[:space:]]@ .*$//'
}

audit_one() {  # audit_one <name>
    name=$1
    g=$(find_lib "$GNUTON" "$name") || { echo "$name: not shipped by gnuton"; return 0; }
    s=$(find_lib "$STOCK" "$name")

    printf '%-28s ' "$name"
    if [ -z "$s" ]; then
        echo "SHIP-GNUTON   stock does not provide it"
        return 0
    fi

    gs=$(mktemp); ss=$(mktemp)
    exports "$g" > "$gs"; exports "$s" > "$ss"

    only_g=$(comm -13 "$ss" "$gs")
    only_s=$(comm -23 "$ss" "$gs")

    if [ -n "$only_g" ]; then
        echo "SHIP-GNUTON   $(printf '%s\n' "$only_g" | wc -l) export(s) only in gnuton"
        printf '                %s\n' $(printf '%s\n' "$only_g" | head -3)
        rm -f "$gs" "$ss"; return 0
    fi

    # compare the code of every exported function we can disassemble
    differ=0
    checked=0
    for sym in $(comm -12 "$gs" "$ss"); do
        a=$(norm_disasm "$s" "$sym")
        [ -n "$a" ] || continue
        b=$(norm_disasm "$g" "$sym")
        [ -n "$b" ] || continue
        checked=$((checked + 1))
        if [ "$a" != "$b" ]; then
            differ=$((differ + 1))
            [ "$differ" -le 5 ] && echo "  differs: $sym" >&2
        fi
    done

    if [ "$differ" = "0" ]; then
        echo "KEEP-STOCK    same exports, $checked exported function(s) byte-identical"
    else
        echo "KEEP-STOCK    same exports (code differs in $differ/$checked functions: build flags, not a reason alone)"
    fi
    rm -f "$gs" "$ss"
}

if [ "${1:-}" = "--all" ]; then
    printf '%-28s %s\n' "library" "verdict"
    printf '%-28s %s\n' "----------------------------" "-------"
    for lib in $(find "$GNUTON/lib" "$GNUTON/usr/lib" -maxdepth 1 -name '*.so*' -type f 2>/dev/null | sort -u); do
        audit_one "$(basename "$lib")" 2>/dev/null
    done
else
    [ -n "${1:-}" ] || { echo "usage: $0 <libname>|--all" >&2; exit 2; }
    audit_one "$1"
fi
