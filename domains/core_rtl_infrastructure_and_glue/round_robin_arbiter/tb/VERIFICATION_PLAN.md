# Round Robin Arbiter Verification Plan

## Verification Goals

- Check rotating fairness under sustained multi-request contention.
- Check pointer movement only on `advance`.
- Check masking and wraparound behavior.
- Check one-hot and encoded outputs match exactly.

## Simulation Coverage

The first-pass simulation covers:

- repeated three-way contention with pointer rotation
- pointer hold behavior when `advance = 0`
- masking and wraparound behavior

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants:

- any asserted grant is a subset of `request & mask`
- `grant_valid` matches whether `grant_onehot` is nonzero
- `grant_onehot` is one-hot or zero

## Next Verification Expansions

- parameter sweep automation over requester count
- stronger formal properties for pointer advancement
- randomized fairness stress simulation
