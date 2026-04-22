# Clock Gating Wrapper Verification Plan

## Verification Goals

- Check reset startup policy and quiet disabled behavior.
- Check gate state only changes on the low phase of `clk_in`.
- Check enable open and close behavior does not create unexpected toggles.
- Check test bypass and functional bypass override normal gating.
- Check FPGA-safe mode leaves the clock free-running while exporting policy through `domain_ce`.
- Check active-low enable polarity behavior.

## Simulation Coverage

The first-pass simulation covers:

- reset with gates closed by default
- enable request opening the accepted gate state after synchronization
- disable request closing the accepted gate state and stopping gated-clock edges
- test bypass override behavior
- functional bypass override behavior
- FPGA-safe mode clock passthrough semantics
- active-low enable mode with no synchronizer stages

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset clears `gate_open`
- reset clears `domain_ce`
- reset clears `override_active`
- reset keeps `gated_clk` low when the source clock is held low

## Next Verification Expansions

- randomized phase-swept enable and override updates
- assertions that accepted gate-state transitions only happen when `clk_in` is low
- stronger proofs for no extra gated-clock rising edge after a close request is accepted
