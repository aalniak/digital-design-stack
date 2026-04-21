# Skid Buffer Verification Plan

## Verification Goals

- Check ordered lossless transport under random stalls.
- Check the first late-stall beat is captured instead of lost.
- Check sideband alignment with payload.
- Check reset clearing of stored beats.
- Check bypass mode and multi-stage mode separately.
- Check output stability while a stored beat is stalled.

## Simulation Coverage

The first-pass simulation covers:

- `DEPTH = 0` bypass instance
- `DEPTH = 1` classic skid instance
- `DEPTH = 2` chained skid instance
- directed first-stall behavior for the classic skid case
- random valid and ready stall patterns
- exact payload and sideband ordering checks
- stored-output stability checks

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants for a one-stage skid buffer:

- reset clears output valid when the source follows reset discipline
- reset leaves the source-facing interface ready to accept traffic

## Next Verification Expansions

- parameter sweep automation over depth and sideband width
- stronger formal hold-behavior properties under a valid-ready-aware clocking style
- deeper end-to-end ordering proofs for multi-stage configurations
- throughput-focused checks for steady-state one-beat-per-cycle operation
