# Register Slice Verification Plan

## Verification Goals

- Check ordered lossless transport under random stalls.
- Check sideband alignment with payload.
- Check reset clearing of stored valid state.
- Check bypass mode and multi-stage mode separately.
- Check output stability while stalled.

## Simulation Coverage

The first-pass simulation covers:

- `STAGES = 0` bypass instance
- `STAGES = 2` pipelined instance
- random valid and ready stall patterns
- exact payload and sideband ordering checks
- stalled-output stability checks

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants for a one-stage slice:

- reset clears output valid

## Next Verification Expansions

- parameter sweep automation over stage count and sideband width
- stronger formal stall-stability properties with a clocking style tailored to valid-ready edges
- deeper end-to-end ordering proofs for multi-stage configurations
- throughput-focused checks for steady-state full-bandwidth behavior
