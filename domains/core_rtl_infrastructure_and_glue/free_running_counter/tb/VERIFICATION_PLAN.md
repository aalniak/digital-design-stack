# Free-Running Counter Verification Plan

## Verification Goals

- Check increment, hold, and load behavior.
- Check wrap behavior and rollover pulse timing.
- Check capture semantics against post-update count behavior.
- Check disabled-feature behavior for enable and capture options.

## Simulation Coverage

The first-pass simulation covers:

- gated counting behavior
- always-enabled counting behavior
- synchronous load priority
- capture semantics
- wrap and rollover pulse behavior
- disabled capture mirroring behavior

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants for a rollover-enabled configuration:

- reset values are correct
- rollover pulse only appears when the visible count is zero after a counted wrap
- the pulse is low during reset

## Next Verification Expansions

- parameter sweep automation over widths and reset values
- formal checks for load priority and enable hold behavior
- compare-wrapper verification when the family expands
