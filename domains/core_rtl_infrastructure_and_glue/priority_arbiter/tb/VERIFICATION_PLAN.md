# Priority Arbiter Verification Plan

## Verification Goals

- Check the highest-priority masked request always wins.
- Check masking suppresses otherwise active requests.
- Check one-hot and encoded outputs match exactly.
- Check idle behavior when no masked requests are active.

## Simulation Coverage

The first-pass simulation covers:

- low-index-high-priority instances
- high-index-high-priority instances
- masking behavior
- no-request idle behavior

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants:

- any asserted grant is a subset of `request & mask`
- `grant_valid` matches whether `grant_onehot` is nonzero
- `grant_onehot` is one-hot or zero

## Next Verification Expansions

- parameter sweep automation over requester count
- stronger formal properties for `grant_index` consistency
- wider randomized request-pattern simulation
