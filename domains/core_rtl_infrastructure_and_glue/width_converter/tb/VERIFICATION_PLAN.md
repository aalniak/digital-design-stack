# Width Converter Verification Plan

## Verification Goals

- Check bypass, widening, and narrowing behavior against the documented lane ordering.
- Check `keep` and `last` propagation through partial final groups.
- Check stall behavior while partial state is held internally.
- Check reset returns the converter to an idle state.

## Simulation Coverage

The first-pass simulation covers:

- reset-to-idle behavior
- equal-width pass-through
- widening with a full group and a partial final group
- narrowing with a full beat and a partial final beat
- stall behavior while output state is pending

## Formal Coverage

The first-pass formal harness checks reset-state public-contract invariants:

- reset forces `m_valid` low
- reset forces `busy` low
- reset backpressures the source in the current staged implementation

## Next Verification Expansions

- ratio sweeps across multiple widening and narrowing pairs
- randomized end-to-end reconstruction checks
- deeper formal checks for staged-state evolution
