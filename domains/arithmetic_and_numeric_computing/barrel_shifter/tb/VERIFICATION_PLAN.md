# Barrel Shifter Verification Plan

## Verification Goals

- Check every supported mode.
- Check sticky semantics for left, logical right, and arithmetic right shifts.
- Check rotate-left modulo behavior.
- Check oversize shift semantics explicitly.
- Check sticky suppression when disabled.

## Simulation Coverage

The first-pass simulation covers:

- left shift with discarded-bit sticky
- logical right shift with discarded-bit sticky
- arithmetic right shift with sign extension and sticky
- rotate-left behavior
- oversize logical left shift to zero
- oversize arithmetic right shift to all sign bits
- sticky suppression when `STICKY_BIT_EN = 0`

## Formal Coverage

The first-pass formal harness checks exact combinational behavior for a small-width sticky-enabled instance:

- `data_out` matches the mode-specific shift or rotate result
- `sticky` matches the discarded-bit policy for non-rotate modes and remains zero for rotate mode
