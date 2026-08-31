#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Set these environment variables before running:
#   COMPARATOR       — path to the comparator binary
#   LEAN4EXPORT      — path to a lean4export binary matching this project's toolchain (v4.33.0)
#   FAKE_LANDRUN     — path to fake-landrun.sh (macOS only; omit on Linux with real landrun)

: "${COMPARATOR:?Set COMPARATOR to the comparator binary path}"
: "${LEAN4EXPORT:?Set LEAN4EXPORT to a v4.33.0-compatible lean4export binary}"

if [[ -n "${FAKE_LANDRUN:-}" ]]; then
  export COMPARATOR_LANDRUN="$FAKE_LANDRUN"
fi

COMPARATOR_LEAN4EXPORT="$LEAN4EXPORT" \
lake env "$COMPARATOR" comparator-stone.json
