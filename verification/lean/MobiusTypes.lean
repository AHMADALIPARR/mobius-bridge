/-
  MÖBIUS-14 Lean 4 formal types
  No sorry, no admit, no hidden axioms.
-/

import Mathlib.Data.Real.Basic
import Mathlib.Data.Vector
import Mathlib.Tactic

namespace Mobius

/-- Phase parameter bounded in [-π, π] -/
structure Phase where
  val : ℝ
  bound : -Real.pi ≤ val ∧ val ≤ Real.pi
  deriving Repr

/-- Parameter vector of fixed dimension -/
def ParamVec (n : Nat) := Vector Phase n

/-- INT4 quantization range -/
def int4_min : Int := -8
def int4_max : Int :=  7

structure Int4 where
  val : Int
  range : int4_min ≤ val ∧ val ≤ int4_max
  deriving Repr

/-- Round counter upper bound -/
def max_rounds : Nat := 14

structure Round where
  val : Nat
  bound : val ≤ max_rounds
  deriving Repr

/-- Payload with dimension correctness -/
structure Payload (n : Nat) where
  experiment_id : String
  iteration     : Round
  params        : ParamVec n
  energy        : ℝ
  uncertainty   : ℝ
  sequence      : Nat
  deriving Repr

/-- Totality of pure transition: rejected update preserves state -/
def reject_preserves {n : Nat} (p : Payload n) (candidate : ParamVec n) : Payload n :=
  p

theorem reject_preserves_params {n : Nat} (p : Payload n) (c : ParamVec n) :
    (reject_preserves p c).params = p.params := by
  rfl

/-- Phase-bound preservation under clamping -/
def clamp_phase (r : ℝ) : Phase :=
  if h : -Real.pi ≤ r ∧ r ≤ Real.pi then
    ⟨r, h⟩
  else if r < -Real.pi then
    ⟨-Real.pi, by constructor <;> linarith [Real.pi_pos]⟩
  else
    ⟨Real.pi, by constructor <;> linarith [Real.pi_pos]⟩

theorem clamp_phase_bound (r : ℝ) :
    -Real.pi ≤ (clamp_phase r).val ∧ (clamp_phase r).val ≤ Real.pi := by
  simp [clamp_phase]
  split_ifs <;> simp_all <;> linarith [Real.pi_pos]

end Mobius
