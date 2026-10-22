# MÖBIUS Protocol v1

Message format (big-endian):

| Offset | Size | Field                    |
|--------|------|--------------------------|
| 0      | 4    | length (payload)         |
| 4      | 2    | protocol_version         |
| 6      | 16   | experiment_id (UUID)     |
| 22     | 4    | iteration                |
| 26     | 2    | param_dim                |
| 28     | N×4  | parameters (float32)     |
| …      | 8    | measurement_energy       |
| …      | 8    | uncertainty              |
| …      | 32   | payload_digest (SHA-256) |
| …      | 8    | sequence_id              |

## Rejection Rules

- Malformed framing or length mismatch
- Wrong protocol version
- Stale sequence / iteration
- Oversized payload
- Duplicate sequence ID
- Dimension mismatch
- Non-finite parameters or energy
- Phase values outside [-π, π]
- Digest mismatch
