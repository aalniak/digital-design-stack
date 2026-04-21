# Timer Block Verification Plan

## Verification Goals

- Check one-shot countdown semantics and expiration timing.
- Check periodic reload semantics and repeated expiration timing.
- Check control priority for `clear`, `load`, `stop`, and `start`.
- Check sticky interrupt behavior and acknowledge handling.
- Check prescaler cadence and off-by-one boundaries.

## Simulation Coverage

The first-pass simulation covers:

- reset-state checks
- one-shot countdown timing
- periodic reload timing
- stop and clear behavior
- runtime `load_pulse` reprogramming
- sticky interrupt set and clear behavior
- prescaler timing with nonzero `prescale_div`

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants:

- reset clears `running`
- reset clears `expire_pulse`
- reset clears `irq`
- reset clears `count_value`

## Next Verification Expansions

- parameter sweep automation over count width and prescaler width
- stronger formal properties for expiration timing and control-priority collisions
- repeated-period cadence proofs for periodic mode
- randomized directed-control sequences
