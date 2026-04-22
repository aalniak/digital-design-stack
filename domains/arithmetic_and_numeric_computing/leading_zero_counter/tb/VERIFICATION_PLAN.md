# Leading Zero Counter Verification Plan

## Verification Goals

- Check count and flag behavior for an all-zero input.
- Check count and index behavior for top-bit, interior-bit, and lowest-bit hits.
- Check count and index stay aligned.
- Check index suppression behavior.

## Simulation Coverage

The first-pass simulation covers:

- all-zero input behavior
- MSB already set
- a middle-position highest set bit
- LSB-only highest set bit
- index suppression behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small instance:

- `all_zero` matches whether the input is zero
- `leading_zero_count` matches a software-style search from MSB to LSB
- `msb_index` matches the highest set bit when enabled
