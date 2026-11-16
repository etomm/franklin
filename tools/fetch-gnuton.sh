#!/bin/sh
# Fetch the pinned gnuton reference into vendor/gnuton (gitignored).
# Run from the repo root in WSL / Git Bash (not native Windows cmd),
# because the upstream tree contains filenames invalid on Windows (aux.c).
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Read pinned ref
. ./GNUTON_REF

mkdir -p vendor
if [ -d vendor/gnuton/.git ]; then
  echo "Updating existing reference clone..."
  cd vendor/gnuton
  git fetch --depth 1 origin "$UPSTREAM_COMMIT" || git fetch origin
  git checkout "$UPSTREAM_COMMIT"
else
  echo "Cloning gnuton (shallow) for reference..."
  git clone --depth 1 "$UPSTREAM_URL" vendor/gnuton
  cd vendor/gnuton
  git fetch --depth 1 origin "$UPSTREAM_COMMIT" || true
  git checkout "$UPSTREAM_COMMIT" 2>/dev/null || true
fi

echo "Reference ready at vendor/gnuton (commit $(git rev-parse HEAD))"
echo "NOTE: vendor/ is gitignored. Do not commit upstream source into Franklin."
