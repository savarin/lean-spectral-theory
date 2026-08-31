#!/usr/bin/env python3
"""Audit the compact Palomar boundary and its permitted axioms.

Does NOT verify type-signature equality or inspect the transitive import
boundary. For type-signature verification, use the comparator. For import
boundary verification, inspect StoneChallenge.lean's import list manually (it
must contain only Lean core, Mathlib, TauCeti, or CSLib per Palomar §2.4).

Adapted from the formalization starter kit's check_boundary.py.
"""
import json
import pathlib
import re
import subprocess
import sys

AXIOMS_RE = re.compile(r"'([^']+)' depends on axioms: \[(.*)\]")
NO_AXIOMS_RE = re.compile(r"'([^']+)' does not depend on any axioms")


def fail(msg):
    print(f"FAIL: {msg}")
    sys.exit(1)


def run_lean(path):
    proc = subprocess.run(["lake", "env", "lean", str(path)],
                          capture_output=True, text=True)
    return proc.returncode, proc.stdout + proc.stderr


def main():
    manifest = pathlib.Path(sys.argv[1] if len(sys.argv) > 1
                            else "comparator-stone.json")
    if not manifest.is_file():
        fail(f"{manifest} not found")
    m = json.loads(manifest.read_text())

    challenge = pathlib.Path(f"{m['challenge_module']}.lean")
    solution = pathlib.Path(f"{m['solution_module']}.lean")
    theorems = m["theorem_names"]
    definitions = m.get("definition_names", [])
    permitted = set(m["permitted_axioms"])

    print("=== Boundary check ===")

    # Step 0: Palomar size/import/hole invariants
    raw = challenge.read_text() if challenge.is_file() else ""
    line_count = len(raw.splitlines())
    byte_count = len(raw.encode("utf-8"))
    if line_count > 1000 or byte_count > 100 * 1024:
        fail(f"Challenge exceeds Palomar hard limit: {line_count} lines, "
             f"{byte_count} bytes")
    if line_count > 100 or byte_count > 32 * 1024:
        fail(f"Challenge is not eligible for inline rendering: "
             f"{line_count} lines, {byte_count} bytes")
    imports = re.findall(r"^import\s+([^\s]+)", raw, flags=re.MULTILINE)
    disallowed = [name for name in imports if not name.startswith("Mathlib.")]
    if disallowed:
        fail(f"Challenge has non-Mathlib imports: {disallowed}")
    if m.get("definition_names"):
        fail("this boundary must not use definition holes")
    if len(re.findall(r"\bsorry\b", raw)) != len(theorems):
        fail("Challenge must contain exactly one deliberate sorry per theorem")
    print(f"[0/3] PASS: {line_count} lines, {byte_count} bytes, "
          "Mathlib-only, zero definition holes")

    # Step 1: Elaborate Challenge
    if not challenge.is_file():
        fail(f"{challenge} not found")
    print(f"[1/3] Elaborating {challenge} ...")
    code, out = run_lean(challenge)
    if code != 0:
        print(out.rstrip())
        fail("Challenge does not elaborate")
    print("  PASS: Challenge elaborates")

    # Step 2: Elaborate Solution
    if not solution.is_file():
        fail(f"{solution} not found")
    print(f"[2/3] Elaborating {solution} ...")
    code, out = run_lean(solution)
    if code != 0:
        print(out.rstrip())
        fail("Solution does not elaborate")
    print("  PASS: Solution elaborates")

    # Step 3: Axiom audit (via Solution's imports)
    print("[3/3] Auditing axioms ...")
    scratch = pathlib.Path("_axiom_check.lean")
    all_names = theorems + definitions
    scratch.write_text(
        f"import {m['solution_module']}\n"
        + "".join(f"#print axioms {t}\n" for t in all_names))
    try:
        code, out = run_lean(scratch)
    finally:
        scratch.unlink(missing_ok=True)
    print(out.rstrip())
    if code != 0:
        fail("axiom check did not elaborate")

    # Join continuation lines (Lean wraps long axiom lists with leading whitespace)
    joined = []
    for line in out.splitlines():
        if joined and line and line[0] == ' ':
            joined[-1] += ' ' + line.strip()
        else:
            joined.append(line)

    seen = {}
    for line in joined:
        mo = AXIOMS_RE.match(line)
        if mo:
            seen[mo.group(1)] = {a.strip() for a in mo.group(2).split(",")
                                 if a.strip()}
            continue
        mo = NO_AXIOMS_RE.match(line)
        if mo:
            seen[mo.group(1)] = set()

    bad = False
    for t in all_names:
        if t not in seen:
            print(f"  FAIL: no axiom report for {t}")
            bad = True
            continue
        extra = seen[t] - permitted
        if extra:
            print(f"  FAIL: {t} uses non-permitted axioms {sorted(extra)}")
            bad = True
        else:
            print(f"  ok: {t} uses only permitted axioms")
    if bad:
        fail("axiom audit failed")
    print("  PASS: axioms clean")
    print("=== BOUNDARY CHECK PASSED ===")


if __name__ == "__main__":
    main()
