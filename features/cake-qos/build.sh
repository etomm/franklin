#!/bin/sh
# Build sch_cake.ko for the XT9 (kernel 4.19.183).
set -e
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
: "${GPL:?set GPL to the ASUS GPL zip}"
: "${CONFIG:?set CONFIG to the device kernel config}"
exec sh "$ROOT/tools/build-kernel-modules.sh" \
  --gpl "$GPL" --config "$CONFIG" \
  --enable "NET_SCH_CAKE=m" \
  --modules "net/sched/sch_cake.ko" \
  --out "$ROOT/features/cake-qos/payload" "$@"
