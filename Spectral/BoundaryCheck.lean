import Spectral.Cayley.Inverse
import Spectral.PVM.Unbounded
import Spectral.Spectral.Uniqueness
import Spectral.Spectral.FuncCalc
import Spectral.Stone.Theorem

/-!
Manifest-driven boundary for the spectral-theory surface.

Every declaration below has an explicit type and delegates to the production
declaration. A changed source signature therefore breaks elaboration, while
the manifest separately audits the production declaration's axioms.
-/

namespace StoneBoundary

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
  [CompleteSpace E]

-- Layer 1: Cayley transform
example (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A) :
    cayleyTransform A hA ∈ unitary (E →L[ℂ] E) :=
  cayleyTransform_unitary A hA

example (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A) :
    ∀ x, cayleyTransform A hA x = x → x = 0 :=
  one_not_mem_eigenvalues_cayleyTransform A hA

example (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A) :
    DenseRange (fun x => x - cayleyTransform A hA x) :=
  dense_range_one_sub_cayleyTransform A hA

example (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A) :
    inverseCayley (cayleyTransform A hA) (cayleyTransform_unitary A hA)
      (one_not_mem_eigenvalues_cayleyTransform A hA)
      (dense_range_one_sub_cayleyTransform A hA) = A :=
  inverseCayley_cayleyTransform A hA

-- Layer 3: Spectral theorem
example (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A) :
    ∃ E_pvm : PVM E,
      E_pvm.unboundedIntegral ((↑) : ℝ → ℂ) Complex.continuous_ofReal.measurable = A :=
  spectral_theorem_existence A hA

example (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A)
    (E₁ E₂ : PVM E)
    (h₁ : E₁.unboundedIntegral ((↑) : ℝ → ℂ) Complex.continuous_ofReal.measurable = A)
    (h₂ : E₂.unboundedIntegral ((↑) : ℝ → ℂ) Complex.continuous_ofReal.measurable = A)
    (S : Set ℝ) (hS : MeasurableSet S) :
    E₁.proj S = E₂.proj S :=
  spectral_theorem_uniqueness A hA E₁ E₂ h₁ h₂ S hS

end StoneBoundary
