#!/bin/sh
# boot-hook: nothing to start. This hook exists so every feature is uniform:
# the asusware shim boots Franklin and this runs immediately after it.
set -u
echo "boot-hook: usb=${USB:-?} root=${FRANKLIN_ROOT:-?}"
exit 0
