#!/bin/sh
# Deploy a composed stick image onto the mounted USB key, in place.
#
#   wsl tar -C build/usb -cf - . | ssh router 'sh tools/deploy-usb.sh'
#
# Why a script instead of a bare `tar xf -`: extracting over a live tree never
# deletes anything, so stale feature directories and stale registry entries
# accumulate across builds. franklin-boot walks registry.d/*.env with no
# de-duplication, so an old 003-web-ui-overlay.env plus a new 009-... one runs
# the same start hook twice (double overlay mounts, double cron lines).
#
# This script extracts into a staging directory on the stick first, prunes the
# tree to match the incoming composition, then copies the result over. Features
# missing from the new composition are removed; everything else is replaced.
#
#   USB=/tmp/mnt/FRANKLIN   target mount point (default)
#
# The copy is additive: installed packages under franklin/opt and runtime state
# under franklin/state are never deleted, and the build tree carries no package
# files, so an extraction cannot clobber them. (Do not "protect" the whole of
# franklin/opt: the web UI delta itself lives in opt/share/gnuton-www.)
set -eu

USB="${USB:-/tmp/mnt/FRANKLIN}"
KEEP_DATA="${KEEP_DATA:-1}"
stage="$USB/.franklin-deploy.$$"

cleanup() { rm -rf "$stage"; }
trap cleanup EXIT INT TERM

[ -d "$USB" ] || { echo "deploy: $USB not mounted" >&2; exit 1; }
mkdir -p "$stage"
tar xf - -C "$stage"

[ -x "$stage/franklin/bin/franklin-boot" ] || {
    echo "deploy: archive has no franklin/bin/franklin-boot (wrong payload?)" >&2
    exit 1
}
[ -d "$stage/franklin/registry.d" ] || {
    echo "deploy: archive has no registry.d (incomplete composition)" >&2
    exit 1
}

# --- prune feature directories this composition does not ship --------------
# The staged tree is authoritative: a feature directory exists exactly when the
# composition has private payload files for it. Comparing against the stage
# (not against registry entries) also removes leftover directories of features
# that only merge into prefix dirs, such as the web UI.
removed=""
if [ -d "$USB/franklin/features" ]; then
    for d in "$USB"/franklin/features/*; do
        [ -d "$d" ] || continue
        id=$(basename "$d")
        if [ ! -d "$stage/franklin/features/$id" ]; then
            rm -rf "$d"
            removed="$removed $id"
        fi
    done
fi

# --- registry is generated, never merged ------------------------------------
rm -rf "$USB/franklin/registry.d"

# --- copy the new tree ------------------------------------------------------
# franklin/opt additionally holds installed packages and franklin/state holds
# runtime state (overlay upper, wifi-insight DB, traffic DB). The copy only
# adds/overwrites the build's own files; nothing outside the archive is
# removed here except the stale features and registry handled above.
cp -a "$stage"/. "$USB"/

count=$(ls "$USB"/franklin/registry.d/*.env 2>/dev/null | wc -l)
features=$(ls -d "$USB"/franklin/features/*/ 2>/dev/null | wc -l)
echo "deploy: $features feature dir(s), $count registry entr(ies) on $USB"
[ -n "$removed" ] && echo "deploy: pruned$removed"
echo "deploy: note - running processes keep the old code until the next boot"
exit 0
