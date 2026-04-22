# Divider Verification Plan

## Verification Goals

- Check exact unsigned quotient and remainder behavior.
- Check exact signed quotient and remainder behavior.
- Check divide-by-zero policy outputs.
- Check signed overflow behavior on `SIGNED_MIN / -1`.
- Check remainder suppression behavior.

## Simulation Coverage

The first-pass simulation covers:

- unsigned exact division
- signed exact division with negative dividend
- divide-by-zero policy
- signed overflow saturation behavior
- remainder suppression behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small signed configuration:

- quotient, remainder, divide-by-zero, and overflow match the documented policy for all input combinations
