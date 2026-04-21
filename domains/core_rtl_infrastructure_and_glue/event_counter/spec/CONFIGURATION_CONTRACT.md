# Event Counter Configuration Contract

## Implemented Configuration Surface

The current `event_counter` implementation provides a reusable synchronous statistics primitive with the following parameter set:

- `COUNT_WIDTH`
  - width of the live counter and snapshot register
  - legal range in the current implementation: `COUNT_WIDTH >= 1`
- `SATURATE`
  - `0` means the counter wraps on overflow
  - `1` means the counter clamps at the maximum representable value
- `THRESHOLD_EN`
  - `1` enables the threshold comparator output
  - `0` forces the threshold output low while keeping a stable port set
- `THRESHOLD_VALUE`
  - compare level used when `THRESHOLD_EN = 1`
- `SNAPSHOT_EN`
  - `1` enables explicit snapshot capture through `snapshot`
  - `0` makes `snapshot_value` mirror the live count for a stable interface
- `CLEAR_PRIORITY`
  - `1` means `clear` wins over a simultaneous event
  - `0` means a simultaneous clear and event counts from `RESET_VALUE`
- `RESET_VALUE`
  - reset and clear value for the live counter and snapshot register

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `event_pulse`
  - one-cycle local event indication to be counted
- `count_enable`
  - qualifies whether `event_pulse` is allowed to increment the counter
- `clear`
  - clears the live count and sticky overflow state according to the configured clear policy
- `snapshot`
  - captures the post-update visible count into `snapshot_value` when `SNAPSHOT_EN = 1`
- `count_value`
  - live counter value
- `snapshot_value`
  - captured or mirrored counter value, depending on `SNAPSHOT_EN`
- `overflow_sticky`
  - sticky overflow indicator that clears with reset or `clear`
- `threshold_reached`
  - level output indicating `count_value >= THRESHOLD_VALUE` when enabled

## Behavioral Contract

- Only local synchronous events may be applied directly to `event_pulse`.
- A qualified event is `event_pulse && count_enable`.
- `clear` resets the live count to `RESET_VALUE`.
- If `CLEAR_PRIORITY = 1`, a simultaneous clear and qualified event leaves the count at `RESET_VALUE`.
- If `CLEAR_PRIORITY = 0`, a simultaneous clear and qualified event increments from `RESET_VALUE`.
- `snapshot` captures the post-update count visible for that cycle.
- `overflow_sticky` records an overflow attempt and remains high until reset or `clear`.

## Current Implementation Notes

- The current RTL keeps a stable public port set even when threshold or snapshot features are disabled.
- Threshold signaling is level-based rather than pulsed.
- The first-pass family focuses on the local synchronous counter core rather than a wider CSR wrapper family.

## Illegal Configurations

- `COUNT_WIDTH < 1`

## Planned Future Expansion

- optional pulse output on threshold crossing
- optional separate sticky threshold flag
- optional freeze input distinct from `snapshot`
- CSR-facing wrappers with explicit read-clear semantics
