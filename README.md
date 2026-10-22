# MÖBIUS-14 Cartography Engine

Sovereign distributed quantum–classical optimization engine connecting Elixir/OTP, MATLAB, PowerShell, Lean 4, Liquid Haskell, CUDA-Q, and heterogeneous edge compute.

## Architecture

```
MÖBIUS-14 CARTOGRAPHY
         │
ELIXIR/OTP SUPERVISOR
         │
  TCP INGESTION
         │
TELEMETRY VALIDATION
         │
HAMILTONIAN EVALUATOR
         │
 CYCLE-STEALING
  WORK SCHEDULER
         │
   ┌─────┴─────┐
MATLAB ENGINE  POWERSHELL
Numeric Solver Control / Routing
   └─────┬─────┘
         │
14-ROUND MÖBIUS
 RECURSIVE LOOP
         │
 LEAN 4 VALIDATOR
         │
LIQUID HASKELL
PROTOCOL CHECKER
         │
 VERIFIED PAYLOAD
         │
  CUDA-Q BACKEND
         │
   ┌─────┴─────┐
NVIDIA CUDA   QPU ADAPTER
 SIMULATION   (FUTURE)
   └─────┬─────┘
         │
  MEASUREMENT
         │
 FEEDBACK LOOP
```

## Quick Start

```bash
# Elixir supervisor + tests
cd supervisor/elixir && mix deps.get && mix test

# Lean 4 proofs (zero sorry)
cd verification/lean && lake build

# Liquid Haskell protocol checks
cd verification/liquid-haskell && stack build

# Full 14-round acceptance test
mix run integration/full_14_round_test.exs
```

## Protocol

Length-prefixed, versioned binary messages over authenticated TCP.
Every message contains protocol version, experiment ID, iteration, parameter dimension, canonically encoded parameters, measurement metadata, payload digest, and monotonic sequence identifier.

Malformed, stale, oversized, duplicate, or out-of-bounds payloads are rejected.

## Acceptance Criteria Met

- Complete 14-round optimization run against reproducible simulator
- Parameter handoff MATLAB → Elixir → CUDA-Q / CPU
- PowerShell-based scheduling on authorized Windows worker
- Validated phase bounds and INT4 conversion
- Rejection of corrupted TCP payloads
- Recovery after worker termination
- Bounded CPU / memory utilization
- Deterministic replay of accepted-state histories
- Explicit numerical + measurement uncertainty reporting
- Zero Lean `sorry` declarations in trusted proof modules

## License

Research / internal use. See LICENSE.
