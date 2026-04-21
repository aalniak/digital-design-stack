# Interrupt Controller Verification Plan

## Verification Goals

- Check edge and level source handling separately.
- Check fixed-priority selection for simultaneous enabled pending sources.
- Check that masked sources still accumulate pending state.
- Check that software-set pending bits behave like sticky requests.
- Check vector output consistency with the selected one-hot source.

## Simulation Coverage

The first-pass simulation covers:

- reset-state checks
- edge-source pulse capture and acknowledge
- simultaneous-source priority resolution
- masked pending accumulation followed by unmask delivery
- level-source acknowledge behavior while the level remains asserted
- software-set pending injection and clear

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants:

- reset clears `pending_status`
- reset clears `irq`
- `active_onehot` is always a subset of enabled pending sources
- `irq` matches whether `active_onehot` is nonzero

## Next Verification Expansions

- parameter sweep automation over source count
- stronger formal proofs for fixed-priority `irq_id` selection
- repeated simultaneous-event stress testing
- hierarchical-controller composition checks
