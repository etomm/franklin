#!/bin/sh
# Unload cake only if nothing is using it.
set -u
grep -q '^sch_cake ' /proc/modules 2>/dev/null || exit 0
rmmod sch_cake 2>/dev/null && echo "cake-qos: unloaded"
exit 0
