# Stream Demux Verification Plan

## Verification Goals

- Check only the selected output sees valid traffic.
- Check `s_ready` follows only the selected output for valid routes.
- Check held-route mode prevents mid-packet route changes.
- Check invalid-route handling matches the configured drop policy.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- single-beat routing to multiple outputs
- backpressure on the selected output
- held-route packet steering across multiple beats
- invalid-route drop behavior

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset clears the held-route state
- no output valid is asserted during reset
- `invalid_route` is low during reset

## Next Verification Expansions

- randomized packet-route sequences with changing select inputs
- stronger formal checks for held-route transitions
- explicit verification of stall mode for invalid routes when `DROP_ON_INVALID = 0`
