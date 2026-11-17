#!/bin/sh
# A recipe, not a payload: every kernel feature owns and loads its own .ko.
# Resolve the Franklin root when run by hand; the boot driver exports it.
if [ -z "${FRANKLIN_ROOT:-}" ]; then
    FRANKLIN_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
    export FRANKLIN_ROOT
fi

set -u
count=$(ls "${FRANKLIN_ROOT:?}"/features/*/*.ko 2>/dev/null | wc -l)
echo "kernel-modules: $count module(s) staged across features"
exit 0
