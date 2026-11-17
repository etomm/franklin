#!/bin/sh
# Kernel modules are loadable only in dependency order and only once.
# Each feature below loads its own .ko files; nothing is loaded here.
set -u
echo "kernel-modules: $(ls "${FRANKLIN_ROOT:?}/kmod"/*/*.ko 2>/dev/null | wc -l) module(s) staged"
exit 0
