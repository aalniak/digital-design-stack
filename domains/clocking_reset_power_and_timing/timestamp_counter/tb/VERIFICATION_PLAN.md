# Timestamp Counter Verification Plan

## Verification Goals

- Check reset clears the timestamp and output pulses.
- Check normal increments and tick pulses when enabled.
- Check capture returns the pre-update timestamp value.
- Check load overrides normal increment behavior.
- Check compare-hit and overflow pulses fire on the correct updated count.

## Simulation Coverage

The first-pass simulation covers:

- reset and idle behavior
- repeated incrementing
- capture behavior
- synchronous load behavior
- compare-hit pulse generation
- overflow pulse generation on wraparound

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset clears timestamp and pulses

The formal harness intentionally stays lightweight. It does not try to prove:

- sampled-control relationships for `tick_pulse`, `capture_valid`, or `compare_hit`
- exact compare or overflow timing across arbitrary control changes
