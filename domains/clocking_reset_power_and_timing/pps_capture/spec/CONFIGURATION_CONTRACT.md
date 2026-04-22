# PPS Capture Configuration Contract

## Implemented Configuration Surface

The current `pps_capture` baseline provides a qualified edge capture wrapper with the following parameter set:

- `TIMESTAMP_WIDTH`
  - width of the sampled local timestamp bus
  - legal values: integers `>= 1`
- `EDGE_MODE`
  - selects which PPS transition is captured
  - legal values: `0` for rising, `1` for falling
- `FILTER_EN`
  - enables level-qualification filtering before edge detection
  - legal values: `0` or `1`
- `FILTER_CYCLES`
  - number of consecutive samples required before a qualified level transition commits
  - legal values: integers `>= 1`
- `INTERVAL_MEASURE_EN`
  - enables timestamp delta generation between consecutive captures
  - legal values: `0` or `1`
- `CDC_MODE`
  - selects direct sampling or a two-flop synchronizer on `pps_in`
  - legal values: `0` for direct sample, `1` for synchronized sample

## Ports

- `timestamp_in`
  - local timebase presented in the capture clock domain
- `clk`
  - local capture clock
- `rst_n`
  - active-low reset
- `enable`
  - enables PPS capture and resets first-capture history when deasserted
- `pps_in`
  - external PPS input
- `clear_flags`
  - clears sticky glitch-reject status
- `capture_valid`
  - one-cycle pulse on a selected qualified edge
- `captured_timestamp`
  - timestamp captured on the most recent valid PPS event
- `interval_valid`
  - one-cycle pulse when a valid interval delta is produced
- `interval_delta`
  - delta between the current and previous captured timestamps
- `first_capture_seen`
  - indicates at least one valid PPS event has been captured since enable or reset
- `selected_edge_pulse`
  - one-cycle pulse on the selected qualified edge
- `glitch_reject_pulse`
  - one-cycle pulse when a filtered transition is rejected before commitment
- `glitch_reject_sticky`
  - sticky indication that at least one transient PPS glitch was rejected
- `qualified_level`
  - qualified PPS level after synchronization and optional filtering

## Behavioral Contract

- The module captures a local timestamp on the selected qualified PPS edge.
- The first valid capture sets `first_capture_seen` but does not generate `interval_valid`.
- `interval_valid` only pulses on the second and later captures when `INTERVAL_MEASURE_EN = 1`.
- With `FILTER_EN = 1`, level transitions commit only after `FILTER_CYCLES` consecutive samples.
- Reverted candidate transitions generate `glitch_reject_pulse` and latch `glitch_reject_sticky`.
- Deasserting `enable` clears capture history and forces the qualified level back to `0`.

## Current Implementation Notes

- The baseline captures the sampled local timestamp directly and does not attempt sub-cycle compensation.
- `CDC_MODE = 1` adds a two-flop synchronizer for asynchronous PPS inputs.
- This first implementation focuses on qualified capture and interval measurement rather than absolute one-second fault classification.

## Illegal Configurations

- `TIMESTAMP_WIDTH < 1`
- `EDGE_MODE` not in `{0, 1}`
- `FILTER_EN` not in `{0, 1}`
- `FILTER_CYCLES < 1`
- `INTERVAL_MEASURE_EN` not in `{0, 1}`
- `CDC_MODE` not in `{0, 1}`

## Planned Future Expansion

- explicit missing-pulse and double-pulse interval classification
- selectable both-edge capture profile
- optional capture-uncertainty estimate for synchronized asynchronous PPS inputs
