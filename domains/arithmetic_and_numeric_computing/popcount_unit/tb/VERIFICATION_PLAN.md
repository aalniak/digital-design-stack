# Popcount Unit Verification Plan

## Verification Goals

- Check exact count behavior on representative patterns.
- Check zero and full flag behavior.
- Check that flag suppression does not alter count behavior.
- Check that the output matches a software-style bit count exactly.

## Simulation Coverage

The first-pass simulation covers:

- all-zero input
- all-one input
- sparse mixed pattern
- alternating-bit pattern
- flag suppression behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small instance:

- `count_out` matches a software-style sum of input bits
- `is_zero` matches whether the count is zero
- `is_full` matches whether the count equals `DATA_WIDTH`
