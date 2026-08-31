# lean-spectral-theory

The spectral theorem for unbounded self-adjoint operators and
Stone's one-parameter unitary correspondence on complex Hilbert
spaces, formalized in Lean 4 against Mathlib. Prepared for
submission to [Palomar](https://palomar-registry.org).

## Main results

For a self-adjoint partial linear operator on a complex Hilbert space:

- `spectral_theorem_intrinsic`: there exists a real projection-valued
  measure whose scalar moments recover the inner products of the
  operator, with Borel-set uniqueness.
- `stone_theorem_intrinsic`: every strongly continuous one-parameter
  unitary group has a self-adjoint generator, and every self-adjoint
  operator generates such a group.

## Scope

The spectral theorem is the central structure theorem of operator theory
on Hilbert spaces. It decomposes any self-adjoint operator into a
weighted average over projections, analogous to diagonalizing a matrix.
Stone's theorem extends this to one-parameter groups, connecting
self-adjoint operators to quantum mechanics and semigroup theory.

The proof follows the Cayley-transform/PVM route described in
Schmüdgen's *Unbounded Self-adjoint Operators on Hilbert Space* and
Reed and Simon's *Methods of Modern Mathematical Physics I*. The
formalization covers the full unbounded case; Borel-set uniqueness
is proved through Stone's theorem (equal generators ⟹ equal unitary
groups ⟹ equal Fourier transforms of scalar measures ⟹ equal PVMs),
not as an independent parallel result. The proof library also
formalizes bounded and unbounded spectral integrals and a measurable
functional calculus. The audience is researchers in functional
analysis and the formalization community working on operator theory
in Lean/Mathlib.

For a detailed proof route in plain mathematics, see
`BLUEPRINT.md`.

## Trust boundary

- `StoneChallenge.lean` (101 lines) imports only Mathlib. Every
  definition needed by the theorem statements is given
  explicitly — zero definition holes. Only the two advertised
  theorem proofs are omitted.
- `StoneSolution.lean` imports the completed proof development.
- `comparator-stone.json` lists both theorems and no definition holes.
- The proved declarations use only `propext`, `Quot.sound`, and
  `Classical.choice`.

## Proof architecture

```text
self-adjoint A
     │
     ├── Cayley transform ──► unitary U
     │                         │
     │                         └── continuous functional calculus
     │                                      │
     └──────────────────────────────► real PVM P
                                            │
                     bounded truncations ──┤
                                            ▼
                         A = ∫ λ dP(λ)
                                            │
                         scalar moments + polarization
                                            ▼
                 intrinsic existence and Borel uniqueness
                                            │
                         phases exp(i t λ) ─┘
                                            ▼
                       strongly continuous U(t)
                                            ⇅
                           self-adjoint generator
```

Principal source files:

- `Spectral/Cayley/`: Cayley transform and inverse;
- `Spectral/PVM/`: PVMs and bounded/unbounded spectral integrals;
- `Spectral/Spectral/Existence.lean`: constructed integral equality;
- `Spectral/Spectral/Uniqueness.lean`: Borel-set uniqueness;
- `Spectral/Spectral/Intrinsic.lean`: intrinsic equivalence and the
  submitted spectral capstone;
- `Spectral/Stone/Intrinsic.lean`: intrinsic generator relation and
  the submitted Stone capstone.

## Build and verify

Lean and Mathlib 4.33.0 are pinned.

```bash
lake exe cache get
lake build
python3 scripts/check_boundary.py
```

For a local Comparator smoke test:

```bash
export COMPARATOR=/path/to/comparator
export LEAN4EXPORT=/path/to/lean4export
export FAKE_LANDRUN=/path/to/fake-landrun.sh  # macOS only
scripts/run_comparator.sh
```

The submission boundary was validated on 2026-08-30 with both Lean's
default kernel and NanoDa. Palomar runs its own pinned
Comparator, Landrun sandbox, and NanoDa kernel.

## Notes

**Why the statement is intrinsic.** The implementation constructs an
unbounded spectral integral by bounded truncation. Exposing that
construction in StoneChallenge.lean would make the statement depend on
roughly 1,500 lines of implementation details. Instead,
`PVM.Represents` records the standard scalar-measure
characterization. The library proves this characterization is
equivalent to the operator equation
`P.unboundedIntegral (λ ↦ λ) = A`, using complex polarization to
recover every mixed matrix coefficient. Likewise,
`StrongContUnitary.Generates`
states Stone's generator relation without exposing the library's
construction. The compact Challenge is not a weakened surrogate.

## License

Apache-2.0.
