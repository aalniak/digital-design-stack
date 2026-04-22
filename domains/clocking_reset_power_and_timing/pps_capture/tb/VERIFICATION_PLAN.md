# PPS Capture Verification Plan

## Verification Goals

- Check the first valid PPS edge captures a timestamp without producing an interval.
- Check the second and later captures produce the expected timestamp delta.
- Check filtered glitches are rejected and flagged.
- Check qualified edge behavior with synchronized asynchronous sampling.
- Check enable and clear behavior around stored state.

## Simulation Coverage

The first-pass simulation covers:

- first-capture arming behavior
- rising-edge qualified capture
- interval measurement between captures
- short transient glitch rejection
- sticky glitch clear handling
- falling-edge capture in an unfiltered profile

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset keeps capture and interval pulses low
- `interval_valid` only occurs after `first_capture_seen`
- `capture_valid` and `selected_edge_pulse` rise together
- glitch-reject pulse implies sticky capture support is active
