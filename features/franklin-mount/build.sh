#!/bin/sh
# Build the static ARM mount helper into payload/opt/bin/franklin-mount.
#
# Needs a cross compiler: CROSS_COMPILE defaults to arm-linux-gnueabi-.
# Runs on Windows via WSL/Docker (see docs/build-architecture.md).
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
CC="${CC:-${CROSS_COMPILE:-arm-linux-gnueabi-}gcc}"
OUT="${OUT:-$ROOT/features/franklin-mount/payload}"

command -v "$CC" >/dev/null 2>&1 || {
    echo "missing cross compiler: $CC (set CC=...)" >&2
    exit 1
}

mkdir -p "$OUT/opt/bin"
"$CC" -static -O2 -s -o "$OUT/opt/bin/franklin-mount" "$ROOT/tools/franklin-mount.c"
"$CC" -static -O2 -s -o "$OUT/opt/bin/franklin-exec" "$ROOT/tools/franklin-exec.c"
chmod 755 "$OUT/opt/bin/franklin-mount" "$OUT/opt/bin/franklin-exec"
touch -d '@0' "$OUT/opt/bin/franklin-mount" "$OUT/opt/bin/franklin-exec" 2>/dev/null || true
echo "built $OUT/opt/bin/franklin-mount ($(wc -c <"$OUT/opt/bin/franklin-mount") bytes)"
echo "built $OUT/opt/bin/franklin-exec ($(wc -c <"$OUT/opt/bin/franklin-exec") bytes)"
