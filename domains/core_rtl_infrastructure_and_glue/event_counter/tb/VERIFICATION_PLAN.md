# Event Counter Verification Plan

## Verification Goals

- Check wrap and saturate behaviors separately.
- Check threshold signaling.
- Check snapshot capture against post-update count semantics.
- Check sticky overflow behavior and clear behavior.
- Check simultaneous clear and event handling under both clear-priority modes.

## Simulation Coverage

The first-pass simulation covers:

- wrap-mode counting and overflow
- saturate-mode counting and overflow
- threshold assertion
- snapshot capture
- clear-only cycles
- simultaneous clear and event with both priority modes

## Formal Coverage

The first-pass formal harness proves selected public-contract invariants for a saturating configuration:

- reset values are correct
- clear drives the counter and sticky overflow back to reset state on the next visible cycle
- threshold output matches the live count compare

## Next Verification Expansions

- parameter sweep automation over widths and mode combinations
- formal properties for wrap behavior and snapshot semantics
- regression coverage for non-zero `RESET_VALUE`
- threshold-crossing pulse wrapper verification if that family is added
