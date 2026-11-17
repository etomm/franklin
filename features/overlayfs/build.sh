#!/bin/sh
# Build overlay.ko + exportfs.ko for the XT9 (kernel 4.19.183).
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
: "${GPL:?set GPL to the ASUS GPL zip}"
: "${CONFIG:?set CONFIG to the device kernel config}"
exec sh "$ROOT/tools/build-kernel-modules.sh" \
  --gpl "$GPL" --config "$CONFIG" \
  --enable "OVERLAY_FS=m EXPORTFS=m" \
  --modules "fs/exportfs/exportfs.ko fs/overlayfs/overlay.ko" \
  --out "$ROOT/features/overlayfs/payload" "$@"
