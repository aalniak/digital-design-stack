# Timestamp Counter Configuration Contract

## Implemented Configuration Surface

The current `timestamp_counter` baseline provides a free-running timestamp source with the following parameter set:

- `COUNTER_WIDTH`
  - width of the timestamp register and comparison values
  - legal values: integers `>= 1`

## Ports

- `clk`
  - timestamp clock domain
- `rst_n`
  - active-low reset
- `enable`
  - increments the counter by one each cycle when asserted
- `clear`
  - synchronously clears the timestamp to zero
- `load`
  - synchronously loads `load_value` into the timestamp
- `load_value`
  - value written into the timestamp when `load = 1`
- `capture_req`
  - captures the pre-update timestamp into `capture_value`
- `compare_enable`
  - enables compare-hit pulse generation
- `compare_value`
  - value checked against the post-update timestamp
- `timestamp`
  - current free-running timestamp
- `capture_value`
  - latched captured timestamp sample
- `tick_pulse`
  - one-cycle pulse when the counter increments normally
- `capture_valid`
  - one-cycle pulse when `capture_value` updates
- `compare_hit`
  - one-cycle pulse when the new timestamp equals `compare_value`
- `overflow_pulse`
  - one-cycle pulse when normal increment wraps around

## Behavioral Contract

- `clear` has highest priority and sets the timestamp to zero.
- `load` has next priority and writes `load_value` into the timestamp.
- `enable` increments the timestamp by one when neither `clear` nor `load` is asserted.
- Capture records the pre-update timestamp value.
- Compare checks the post-update timestamp value.

## Current Implementation Notes

- This baseline intentionally uses one-count increments rather than a programmable step size.
- The capture path samples the timestamp value visible before the current cycle’s update.
- The compare path uses the value that will become the new timestamp after the current cycle.

## Illegal Configurations

- `COUNTER_WIDTH < 1`

## Planned Future Expansion

- programmable increment step
- PPS or external time-discipline correction hooks
- multiple capture channels
