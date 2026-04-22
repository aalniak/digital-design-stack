# Saturating Adder Verification Plan

## Verification Goals

- Check signed positive and signed negative clipping.
- Check unsigned clipping independently from signed mode.
- Check custom-limit mode against caller-provided bounds.
- Check carry-in behavior when enabled.
- Check clipping flags assert only on actual clipping.

## Simulation Coverage

The first-pass simulation covers:

- signed in-range addition
- signed positive overflow saturation
- signed negative overflow saturation
- unsigned saturation to all ones
- carry-in increment behavior
- custom signed limit saturation in both directions
- flag suppression behavior

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small-width signed custom-limit instance:

- result matches the mathematically clipped widened sum
- `saturated` matches whether the sum is outside the active range
- `at_min` and `at_max` match the selected clip direction
