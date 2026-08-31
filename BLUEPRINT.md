# Blueprint

Plain-mathematics proof route for the spectral theorem for unbounded
self-adjoint operators and Stone's one-parameter unitary
correspondence.

## Target

Two theorems for a self-adjoint operator A on a complex Hilbert space:

1. There exists a real projection-valued measure whose scalar moments
   recover the inner products of the operator, with Borel-set
   uniqueness.

2. Every strongly continuous one-parameter unitary group has a
   self-adjoint generator, and every self-adjoint operator generates
   such a group.

## Proof route

**Layer 1 — the Cayley transform.** For a self-adjoint A, both A + iI
and A − iI are bijections from dom(A) onto the entire Hilbert space.
Surjectivity uses a two-part argument: the range is closed (from the
identity ‖(A ± iI)x‖² = ‖Ax‖² + ‖x‖², convergence of (A ± iI)xₙ
forces convergence of both xₙ and Axₙ, landing back in the closed
graph), and the orthogonal complement of the range is trivial (a
vector orthogonal to ran(A + iI) satisfies Ay = −iy, which combined
with self-adjointness forces y = 0). The Cayley transform
U = (A − iI)(A + iI)⁻¹ is then an isometry, hence extends to a
unitary with no fixed vectors. The inverse Cayley transform
i(I + U)(I − U)⁻¹ recovers A on domain ran(I − U).

**Layer 2 — projection-valued measures and spectral integration.**
A PVM is a map from Borel subsets of ℝ to orthogonal projections,
countably additive in the strong operator topology. Integration is
built in three stages: (a) simple functions integrate as finite
weighted sums of projections; (b) bounded measurable functions
integrate as the operator-norm limit of uniformly-convergent
simple-function approximations; (c) unbounded measurable functions
integrate via truncation — chop f at level n, integrate each bounded
truncation, and take the vector-norm limit. The domain of the
unbounded integral is the vectors x for which ∫|f|² d⟨E(·)x, x⟩ < ∞.
This truncation construction is the technical core.

**Layer 3 — complex polarization (abstract, reusable).** Given a
nonnegative real quadratic function q on a complex normed space
satisfying complex homogeneity and the parallelogram law, reconstruct
a bounded complex sesquilinear form whose diagonal recovers q. The
construction: real polarization (q(x + y) − q(x − y))/4, proved
biadditive via the parallelogram law, extended from rational to real
scalars by continuity, then combined with the i-rotated polarization
into the full complex form. This module contains no spectral-theory
content; it is used twice in the proof.

**Layer 4 — existence (the spectral theorem construction).** Form the
Cayley transform U of A (Layer 1). For each vector x, the map
f ↦ ⟨x, f(U)x⟩ (continuous functional calculus of U) is a positive
linear functional on continuous functions on spectrum(U); the
Riesz–Markov–Kakutani theorem represents it as a finite measure — the
scalar Riesz measure of x. Polarizing this scalar measure at each
Borel set (Layer 3) produces an operator-valued set function.

Proving this is a genuine PVM requires a two-stage promotion:
projection properties (idempotence, countable additivity) are first
established for closed sets by approximating the indicator of a
closed set K with continuous functions max(0, 1 − n · dist(z, K)) and
taking operator-norm limits. These are then promoted from closed to
general Borel sets via inner regularity — approximate any measurable S
by a closed K ⊆ S with μ(S \ K) < 1/(n + 1) and take operator limits
again, using a contraction bound (‖Dx‖² ≤ Re⟨Dx, x⟩ for 0 ≤ D ≤ I)
to turn measure convergence into operator-norm convergence.

Pull the PVM back from the unit circle to ℝ along the inverse Cayley
coordinate z ↦ −Im(z)/(1 − Re(z)). This coordinate is undefined at
z = 1 (the image of ∞ under the classical Cayley correspondence). The
proof must show that {z = 1} has measure zero for every vector: a
self-adjoint operator's Cayley transform has no fixed vectors
(Layer 1), so the projection at the singleton {1} is the zero
operator, and the scalar measure assigns zero mass to that point.

Finally, show this PVM's unbounded coordinate integral equals A:
integrating the forward Cayley phase t ↦ (t − i)/(t + i) against the
PVM recovers U exactly (using the pole-measure-zero result); a
general algebraic lemma converts this into A ⊆ B (the coordinate
integral); and showing B is self-adjoint (via the ±i test-function
trick and linear-algebraic polarization) upgrades containment to
equality.

**Layer 5 — Stone's theorem (both directions).** Proved independently
and before spectral uniqueness.

*Direction 1: unitary group ⟹ self-adjoint generator.* The generator
Ax = lim_{t→0} (U(t)x − x)/(it) is symmetric (via the t ↦ −t
substitution), densely defined (via Riemann-integral mollification:
∫₀ᵃ U(t)x dt is always in the domain, and a⁻¹ times it tends to x),
and closed (direct graph argument). Range surjectivity of A ± iI —
the hard part — uses a Laplace-transform resolvent construction:
y = ∫₀^∞ e⁻ᵗ U(t)x dt solves (A + iI)y = x; the other sign follows
by time-reversing the group. This is structurally unrelated to the
Cayley-transform route used for spectral existence.

*Direction 2: self-adjoint operator ⟹ unitary group.* Reuses the PVM
from Layer 4. Define U(t) = ∫ eⁱᵗʳ dE(r) (a bounded spectral
integral). Show it is unitary (isometry from an L² identity,
surjective via the t ↦ −t inverse), satisfies the group law
(multiplicativity of the integral), and is strongly continuous
(dominated convergence on the scalar measures). Show its generator is
exactly the coordinate integral: one direction by dominated
convergence on the difference quotient, the other by a Fatou/liminf
argument for the domain reverse-inclusion.

**Layer 6 — uniqueness (depends on Stone, not parallel to it).** Given
two PVMs E₁, E₂ both representing the same A: their Layer 5 phase
groups have generators that are literally A in both cases, hence equal
generators. Two strongly continuous unitary groups with the same
generator coincide everywhere — proved via an ODE-constancy trick:
F(s) = U₁(−s)U₂(s)x has derivative zero (a computation combining the
two orbit derivatives), so F is constant, giving U₁(t)x = U₂(t)x on
the dense generator domain, extended by continuity.

Equal unitary groups integrate the same phases, so by Fourier
uniqueness (a measure on ℝ is determined by its characteristic
function) the two PVMs have the same scalar measure for every vector.
Equal scalar measures plus Layer 3 polarization force equal
projections on every measurable set.

**Intrinsic repackaging.** The boundary-file statement does not expose
"the PVM's coordinate integral equals A" (that would leak the
truncation construction). Instead it exposes a scalar-measure
characterization: a PVM represents A when its diagonal matrix
coefficients are its scalar measures, A's domain is the
finite-second-moment vectors, and A's diagonal form is the first
moment. Showing this characterization is equivalent to full operator
equality is a second, independent use of complex polarization — this
time the four-term linear-algebraic identity applied to the operator
itself, reconstructing off-diagonal matrix elements ⟨Tb, a⟩ from four
diagonal values ⟨T(a + cₖb), a + cₖb⟩.

## Key lemmas

1. **Range surjectivity of A ± iI** for self-adjoint A (closed range +
   trivial orthogonal complement). The engine behind the Cayley
   transform and, structurally, Stone's Laplace-resolvent argument.

2. **Complex polarization from a quadratic form.** Used twice: to
   build the projections themselves (existence) and to prove the
   intrinsic characterization equivalent to full operator equality.

3. **Inner-regularity promotion.** Closed-set projections to Borel-set
   projections, via a 1/(n + 1)-approximation and a contraction bound
   that turns measure convergence into operator-norm convergence.
   Roughly half of the existence proof.

4. **Pole-measure-zero.** The Cayley image of ∞ must have zero scalar
   measure for every vector. Proved from the no-fixed-vector property.

5. **The Laplace-transform resolvent** ∫₀^∞ e⁻ᵗ U(t)x dt for Stone's
   direction 1. Structurally unrelated to the Cayley route.

6. **Fourier uniqueness of measures.** The bridge from "equal unitary
   groups" to "equal scalar measures" in the uniqueness proof.

7. **The ODE-constancy trick.** F(s) = U₁(−s)U₂(s)x has zero
   derivative everywhere, so F is constant.

## Pitfalls

1. **The unbounded spectral integral is a truncation limit, not a
   primitive.** Integrating an unbounded function against a PVM is
   built as an L² Cauchy-sequence limit of bounded truncations, with
   every algebraic property re-derived through the limit. This is the
   technical core of the proof, and the intrinsic statement design
   exists precisely to hide this construction from the boundary file.

2. **The point at infinity is a genuine edge case.** The classical
   Cayley correspondence identifies ℝ ∪ {∞} with the unit circle, but
   the inverse Cayley coordinate is undefined at z = 1. The PVM's
   coordinate integral is correct only if that point has measure zero,
   which requires its own proof chain through the no-fixed-vector
   property.

3. **Projection properties are proved on closed sets first, then
   transported by a second limiting argument.** A reader expecting
   "PVM axioms → done" will miss that roughly half of the existence
   proof is this two-stage inner-regularity promotion.

4. **Uniqueness structurally depends on Stone's theorem.** Despite the
   boundary file listing them as two separate theorems, uniqueness
   goes through Stone: compare unitary groups (ODE trick), then
   recover equal PVMs via Fourier uniqueness. A more "direct" PVM
   comparison would fight the actual dependency structure.

5. **Complex polarization does double duty in different senses.** In
   existence it reconstructs an operator from a scalar-valued
   quadratic form; in the intrinsic packaging it reconstructs
   off-diagonal matrix elements from diagonal values. Same identity,
   different applications.

6. **Self-adjointness of the coordinate integral is not immediate.**
   It goes through a two-step detour: real diagonal (via ±i test
   functions), then symmetric-everywhere (via the four-term
   polarization identity).

7. **Stone's two directions use unrelated constructions.** Direction 1
   uses a Laplace-transform resolvent; direction 2 uses the spectral
   PVM. Showing the round-trip composition is the identity routes
   through the entire existence + uniqueness machinery.
