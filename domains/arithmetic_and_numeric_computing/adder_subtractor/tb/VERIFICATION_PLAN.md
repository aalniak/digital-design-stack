# Adder Subtractor Verification Plan

## Verification Goals

- Check plain unsigned addition.
- Check carry-in behavior during addition.
- Check subtraction result and no-borrow indication.
- Check signed overflow behavior separately from carry-out.
- Check zero and negative flags.

## Simulation Coverage

The first-pass simulation covers:

- addition without carry-in
- addition with carry-in and carry-out
- subtraction with and without borrow
- signed positive overflow
- signed subtract overflow

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small-width signed instance:

- result matches the widened add/sub equation
- carry-out matches the widened add/sub equation
- zero flag matches the result
- negative flag matches the sign bit in signed mode
