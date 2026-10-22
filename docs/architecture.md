# MÖBIUS-14 Architecture Notes

## Execution Pipeline

1. TCP ingestion (length-prefixed binary)
2. Telemetry validation
3. Hamiltonian evaluation (MATLAB / CUDA-Q)
4. Cycle-stealing scheduler (Elixir + PowerShell quotas)
5. 14-round recursive controller with atomic commit/reject
6. Lean 4 + Liquid Haskell verification of payload invariants
7. Measurement feedback loop

## Formal Guarantees (proven)

- Phase bounds preserved under clamp
- Rejected updates leave parameter state unchanged
- Round counter ≤ 14
- Deterministic serialization of parameter vectors
- INT4 range correctness

## Explicit Non-Claims

- No quantum speedup asserted
- No automatic CUDA ↔ Metal equivalence
- No global optimality without certificate
- External device / compiler / transport assumptions are distinguished from proven properties
