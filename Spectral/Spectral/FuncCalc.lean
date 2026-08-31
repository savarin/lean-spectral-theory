import Spectral.Spectral.Existence
import Spectral.PVM.Unbounded

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
  [CompleteSpace E]

/-- The measurable spectral functional calculus obtained from a spectral PVM representing `A`. -/
noncomputable def spectralFuncCalc
    (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A)
    (f : ℝ → ℂ) (hf : Measurable f) : E →ₗ.[ℂ] E :=
  (Classical.choose (spectral_theorem_existence A hA)).unboundedIntegral f hf

/-- Applying the spectral functional calculus to the coordinate function recovers `A`. -/
theorem spectralFuncCalc_coordinate
    (A : E →ₗ.[ℂ] E) (hA : IsSelfAdjoint A) :
    spectralFuncCalc A hA ((↑) : ℝ → ℂ)
      Complex.continuous_ofReal.measurable = A := by
  unfold spectralFuncCalc
  exact Classical.choose_spec (spectral_theorem_existence A hA)
