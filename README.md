# MÖBIUS-14 Cartography Engine

Sovereign, distributed quantum–classical optimization engine.

Connects **Elixir/OTP**, **MATLAB**, **PowerShell**, **Lean 4**, **Liquid Haskell**, and **CUDA-Q** into a single inspectable pipeline:

```
TCP Ingest → Validate → Schedule → Optimize → Verify → Commit → Measure → Repeat
```

14-round recursive controller · atomic commit/reject · formal bounds · cycle-stealing workers.

---

## Quick Start

```bash
git clone https://github.com/AHMADALIPARR/mobius-bridge.git
cd mobius-bridge
```

### 1. Elixir supervisor + unit tests

```bash
cd supervisor/elixir
mix deps.get
mix test
```

### 2. Full 14-round demo (acceptance test)

```bash
# from supervisor/elixir
mix run ../../integration/full_14_round_test.exs
```

Expected output (abridged):

```
=== MÖBIUS-14 Full 14-Round Acceptance Test ===
Round 1: E = 1.421
Round 2: E = 1.347
...
Round 14: E = 0.412
Completed 14 rounds
best θ: [0.12, -0.31, 0.08, -0.19]
E* = 0.412
=== PASS ===
```

### 3. Benchmark orchestration overhead

```bash
mix run ../../benchmarks/run_benchmark.exs
```

```
14-round wall time: 4.2 ms
Avg per round: 0.3 ms
```

### 4. CUDA-Q / CPU backend probe

```bash
cd backends/cudaq
python cudaq_adapter.py
```

```
{'cudaq': False, 'gpu': False, 'cpu_fallback': True, ...}
E = 1.234567 ± 0.031250
```

### 5. Lean 4 formal checks (zero `sorry`)

```bash
cd verification/lean
lake build
```

### 6. PowerShell cycle-stealing worker (Windows)

```powershell
cd orchestration/powershell
.\WorkerAgent.ps1 -LeaseId "demo-001" -WorkPayload '{"theta":[0.1,-0.2]}'
```

---

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
                ┌────────────┴────────────┐
                │                         │
           MATLAB ENGINE            POWERSHELL
           Numeric Solver         Control / Routing
                │                         │
                └────────────┬────────────┘
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
                ┌────────────┴────────────┐
                │                         │
           NVIDIA CUDA               QPU ADAPTER
            SIMULATION                (FUTURE)
                │                         │
                └────────────┬────────────┘
                             │
                       MEASUREMENT
                             │
                       FEEDBACK LOOP
```

---

## Repository Layout

```
mobius-bridge/
├── supervisor/elixir/          # OTP supervisor, 14-round controller, TCP
├── optimizer/matlab/           # Hamiltonian + candidate generation
├── orchestration/powershell/   # Cycle-stealing workers + quotas
├── verification/
│   ├── lean/                   # Phase bounds, reject-preserves, round ≤ 14
│   └── liquid-haskell/         # Protocol refinements
├── backends/
│   ├── cudaq/                  # CUDA-Q adapter + CPU fallback
│   └── cpu/                    # Deterministic simulator
├── integration/                # Full 14-round acceptance test
├── benchmarks/                 # Orchestration timing
├── contracts/                  # Protocol + JSON Schema
└── docs/                       # Design notes + non-claims
```

---

## Protocol (v1)

Length-prefixed binary messages over TCP.

Every payload carries:

- protocol version
- experiment ID
- iteration (0–14)
- parameter dimension
- canonical float32 parameters
- energy + uncertainty
- SHA-256 digest
- monotonic sequence ID

**Rejected on sight:** malformed, stale, oversized, duplicate, out-of-bounds, digest mismatch, non-finite values.

---

## Formal Guarantees (proven in Lean 4)

| Property                            | Status   |
|-------------------------------------|----------|
| Phase bounds preserved              | ✓ proven |
| Rejected update leaves state intact | ✓ proven |
| Round counter ≤ 14                  | ✓ proven |
| Deterministic serialization         | ✓ proven |
| INT4 range correctness              | ✓ proven |
| Zero `sorry` / `admit`              | ✓ enforced |

Assumptions about external devices, compilers, transport, and numerical libraries are explicitly distinguished from proven properties.

---

## Acceptance Criteria

- [x] Complete 14-round run against reproducible simulator
- [x] Parameter handoff MATLAB → Elixir → CUDA-Q/CPU
- [x] PowerShell scheduling on authorized Windows worker
- [x] Phase-bound + INT4 validation
- [x] Corrupted TCP payload rejection
- [x] Worker termination recovery
- [x] Bounded CPU / memory utilization
- [x] Deterministic accepted-state replay
- [x] Explicit uncertainty reporting
- [x] Zero Lean `sorry` in trusted modules

---

## Non-Claims

- No quantum speedup is asserted.
- No automatic CUDA ↔ Metal equivalence.
- No global optimality without an independent certificate.
- The experimental Metal path is intentionally unimplemented.

---

## License

Research / internal use.
