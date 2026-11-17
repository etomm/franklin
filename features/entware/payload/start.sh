#!/bin/sh
# Entware lives in franklin/opt (preserved across rebuilds); this only makes
# sure the layout and PATH exist. It never installs packages by itself.
set -u
root="${FRANKLIN_ROOT:?}"
mkdir -p "$root/opt"
for d in bin sbin lib etc tmp var; do mkdir -p "$root/opt/$d"; done
if [ -x "$root/opt/bin/opkg" ]; then
    echo "entware: opkg present"
else
    echo "entware: not installed yet (run the Entware installer into /opt)"
fi
exit 0
