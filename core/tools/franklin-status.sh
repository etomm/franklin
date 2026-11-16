#!/bin/sh
# Quick status dump for Franklin.
echo "=== Franklin status ==="
echo "device: $(cat /jffs/franklin/device/profile.sh 2>/dev/null | grep FRANKLIN_DEVICE || echo unknown)"
echo "--- switch ---"
/jffs/franklin/core/franklin-ethswctl.sh status 2>/dev/null || /bin/ethswctl -c hw-switching
echo "--- logs ---"
tail -20 /tmp/franklin.log 2>/dev/null || echo "no /tmp/franklin.log"
