#!/bin/sh
# A recipe, not a payload: every kernel feature owns and loads its own .ko.
set -u
count=$(ls "${FRANKLIN_ROOT:?}"/features/*/*.ko 2>/dev/null | wc -l)
echo "kernel-modules: $count module(s) staged across features"
exit 0
