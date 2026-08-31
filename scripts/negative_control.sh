#!/bin/bash
# Negative control: confirm the comparator rejects a mutated theorem statement.
#
# Mutates PVM.Represents's second-moment condition in
# SpectralStoneChallenge.lean from `‖(t : ℂ)‖₊ ^ 2` to `‖(t : ℂ)‖₊ ^ 3`, which
# changes spectral_theorem_intrinsic's statement while
# SpectralStoneSolution.lean's redeclared PVM.Represents (and the proof it
# delegates to) still targets the original second-moment condition.
# Temporarily overwrites SpectralStoneChallenge.lean for the mutated build,
# then restores it.
# Requires a passing baseline first.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${COMPARATOR:?Set COMPARATOR to the comparator binary path}"
: "${LEAN4EXPORT:?Set LEAN4EXPORT to a v4.33.0-compatible lean4export binary}"

if [[ -n "${FAKE_LANDRUN:-}" ]]; then
  export COMPARATOR_LANDRUN="$FAKE_LANDRUN"
fi

echo "=== Negative control ==="

# Step 1: Verify baseline passes
echo "[1/3] Verifying baseline ..."
BASELINE=$(COMPARATOR_LEAN4EXPORT="$LEAN4EXPORT" lake env "$COMPARATOR" comparator-spectral-stone.json 2>&1 || true)
if ! echo "$BASELINE" | grep -qi "Your solution is okay"; then
  echo "FAIL: baseline comparator run does not pass — negative control is unreliable"
  echo "$BASELINE" | tail -5
  exit 1
fi
echo "  Baseline passes"

# Step 2: Build a mutated Challenge in a temp directory
echo "[2/3] Building mutated Challenge ..."
WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/neg-ctrl-XXXXXX")

# Save original before any mutation
cp SpectralStoneChallenge.lean "$WORKDIR/SpectralStoneChallenge.lean.orig"
trap 'cp "$WORKDIR/SpectralStoneChallenge.lean.orig" SpectralStoneChallenge.lean; rm -rf "$WORKDIR"; lake build SpectralStoneChallenge SpectralStoneSolution >/dev/null 2>&1 || true' EXIT

# Mutate: change PVM.Represents's second-moment condition from ^2 to ^3
sed 's/‖(t : ℂ)‖₊ \^ 2/‖(t : ℂ)‖₊ ^ 3/' SpectralStoneChallenge.lean > "$WORKDIR/SpectralStoneChallenge.lean"
cp "$WORKDIR/SpectralStoneChallenge.lean" SpectralStoneChallenge.lean

echo "  Mutated: changed PVM.Represents second-moment condition from ^2 to ^3"
if ! lake build SpectralStoneChallenge 2>&1 | tail -3; then
  echo "  (mutated build failed — trap restores SpectralStoneChallenge.lean)"
  exit 1
fi

# Step 3: Run comparator with the mutated Challenge against the unmutated Solution
echo "[3/3] Running comparator on mutated Challenge ..."
OUTPUT=$(COMPARATOR_LEAN4EXPORT="$LEAN4EXPORT" lake env "$COMPARATOR" comparator-spectral-stone.json 2>&1 || true)
echo "$OUTPUT" | tail -5

# Trap restores SpectralStoneChallenge.lean on exit; rebuild to reset .lake cache
echo "  Restoring original and rebuilding ..."  # SpectralStoneChallenge.lean restored by trap on exit

if echo "$OUTPUT" | grep -qi "theorem statement.*do not match\|do not match\|statements.*differ\|typeAlphaEq.*false\|Const does not match"; then
  echo "PASS: comparator correctly rejected the mutated Challenge (statement mismatch)"
  exit 0
else
  echo "FAIL: comparator did not reject with a statement-mismatch error"
  exit 1
fi
