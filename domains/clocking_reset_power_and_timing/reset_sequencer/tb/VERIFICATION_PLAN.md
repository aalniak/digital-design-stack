# Reset Sequencer Verification Plan

## Verification Goals

- Check all resets start asserted.
- Check prerequisite timeout behavior.
- Check reset outputs release in the correct order with the configured spacing.
- Check `ready` only asserts after the final release.
- Check global reset requests restart the sequencer cleanly.

## Simulation Coverage

The first-pass simulation covers:

- idle fully asserted startup
- timeout fault when prerequisites never assert
- fault clear and retry
- ordered release of three reset outputs
- ready assertion after the final release
- restart to idle via global reset request

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset keeps all controlled resets asserted
- `ready` implies no reset remains asserted
- reset exits to a legal public state after release begins

The formal harness intentionally stays lightweight. It does not try to prove:

- exact timeout timing
- one-pulse-per-step sequencing cadence
- mutual exclusion between `timeout_fault` and a later successful retry, because the current design keeps timeout status sticky until `clear_fault`
