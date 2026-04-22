# Abs Min Max Verification Plan

## Verification Goals

- Check signed min and max behavior separately from unsigned behavior.
- Check equality and less-than flags.
- Check negative absolute value conversion.
- Check the signed most-negative abs corner case in saturating and non-saturating modes.
- Check that min and max stay aligned with the compare result.

## Simulation Coverage

The first-pass simulation covers:

- signed compare-select with negative versus positive operands
- equal signed operands
- signed saturating abs on the most-negative input
- unsigned compare-select behavior
- non-saturating most-negative abs behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small-width signed saturating instance:

- `min_value`, `max_value`, `a_eq_b`, and `a_lt_b` match the signed compare result
- `abs_a` matches the signed absolute-value policy including the saturating corner case
- `abs_saturated` matches only the saturating corner case
