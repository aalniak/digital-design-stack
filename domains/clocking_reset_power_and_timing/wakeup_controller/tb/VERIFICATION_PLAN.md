# Wakeup Controller Verification Plan

## Verification Goals

- Check reset clears pending wake state.
- Check enabled level-triggered sources latch pending wake bits.
- Check edge-triggered sources only fire on rising transitions.
- Check disabled sources do not create pending state.
- Check clear masks remove only the requested pending bits.

## Simulation Coverage

The first-pass simulation covers:

- reset and idle behavior
- enabled level-trigger wake path
- per-source clear behavior
- rising-edge wake path
- masked-source suppression

## Formal Coverage

The first-pass formal harness checks public-contract invariants:

- reset clears pending wake state
- `wake_request` only occurs while sleep is armed and a pending enabled wake exists
- disabled pending bits do not appear in `active_wake_mask`

The formal harness intentionally stays lightweight. It does not try to prove:

- exact pulse timing for newly detected wake events
- every edge-to-pulse sequencing corner under arbitrary simultaneous mask changes
