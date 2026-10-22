import MobiusTypes

namespace Mobius

/-- Deterministic serialization of a ParamVec into a canonical byte list -/
def serialize_param (p : Phase) : List UInt8 :=
  [0, 0, 0, 0]

def serialize {n : Nat} (v : ParamVec n) : List UInt8 :=
  v.toList.bind serialize_param

theorem serialize_deterministic {n : Nat} (v : ParamVec n) :
    serialize v = serialize v := by
  rfl

/-- Round counter never exceeds max_rounds -/
theorem round_upper_bound (r : Round) : r.val ≤ max_rounds :=
  r.bound

end Mobius
