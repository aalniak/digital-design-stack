# Clock Enable Generator Verification Plan

## Verification Goals

- Check reset suppresses pulses and clears state.
- Check exact pulse spacing for a one-cycle pulse configuration.
- Check deferred runtime period updates apply only at a period boundary.
- Check multi-cycle pulse width behavior.
- Check restart-on-write phase reset behavior.
- Check bypass and disable behavior.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- one-cycle pulse spacing for period 4
- deferred runtime update from 4 to 5
- two-cycle pulse width for period 5
- immediate restart-on-write from period 6 to 3
- disabled output quiescence
- bypass behavior and immediate apply while bypassed

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `enable_pulse` low
- reset clears `pending_update`
- reset drives `running` low
- reset resets `phase_count` to zero

## Next Verification Expansions

- randomized write timing under both restart policies
- long-run scoreboarding for period and pulse-width correctness
- deeper formal checks for no-missing-pulse and no-double-pulse behavior
