# Clock Fail Detector Verification Plan

## Verification Goals

- Check reset suppresses fault outputs and clears observation state.
- Check healthy monitored activity does not trip fault.
- Check timeout detection latency when the monitored clock stops.
- Check slow and fast monitored clocks trigger window violations.
- Check sticky-fault hold and explicit clear behavior.
- Check non-sticky automatic recovery when monitored activity returns.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- healthy activity inside the accepted min/max window
- timeout assertion after stopping the monitored clock
- sticky-fault persistence until explicit clear
- slow-clock window violation
- fast-clock window violation
- auto-recover behavior in a non-sticky instance

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `fault` low
- reset forces `healthy` low
- reset clears `timeout_event`
- reset clears `window_event`
- reset clears `window_edge_count`

## Next Verification Expansions

- randomized jitter around the min/max acceptance window
- longer-run frequency sweeps near threshold crossings
- deeper formal checks for filter-depth qualification and recovery behavior
