# Complex Multiplier Verification Plan

## Verification Goals

- Check signed complex multiplication across multiple quadrants.
- Check conjugated multiplication behavior.
- Check unsigned multiplication behavior on a non-negative example.
- Check real and imaginary outputs stay aligned with the exact mathematical model.

## Simulation Coverage

The first-pass simulation covers:

- signed complex multiplication without conjugation
- signed complex multiplication with `conjugate_b = 1`
- unsigned multiplication on a simple positive-valued example

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small signed instance:

- `product_re` matches the exact recombined real term
- `product_im` matches the exact recombined imaginary term
- `conjugate_b` is exercised symbolically
