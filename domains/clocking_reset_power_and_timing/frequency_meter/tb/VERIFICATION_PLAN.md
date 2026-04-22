# Frequency Meter Verification Plan

## Verification Goals

- Check reset and disable behavior keep result state quiet.
- Check one-shot measurements produce the expected edge count for known clock ratios.
- Check continuous mode restarts automatically and produces repeated samples.
- Check threshold range flags for low and high counts.
- Check averaging behavior updates `average_count` as expected.

## Simulation Coverage

The first-pass simulation covers:

- reset and disabled-idle behavior
- one-shot in-range measurement
- one-shot above-range measurement
- one-shot stopped-clock measurement
- continuous repeated sampling
- averaging response after a step change in measured-clock rate
- disable clearing busy and result-valid state

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset clears `measured_count` and `average_count`
- reset clears `result_valid`, `sample_valid`, and `busy`
- reset clears threshold flags and `out_of_range`

## Next Verification Expansions

- randomized phase and ratio sweeps across the window boundary
- deeper proofs for one-shot start acceptance and continuous restart behavior
- ratio-accuracy scoreboards across longer measurement campaigns
