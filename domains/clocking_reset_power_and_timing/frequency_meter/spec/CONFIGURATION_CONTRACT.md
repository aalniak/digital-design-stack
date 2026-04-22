# Frequency Meter Configuration Contract

## Implemented Configuration Surface

The current `frequency_meter` baseline measures target-clock edge activity across a reference-clock window using a Gray-coded measured-domain counter and the following parameter set:

- `COUNTER_WIDTH`
  - width of the measured-edge counter and output result fields
  - legal range: `COUNTER_WIDTH >= 1`
- `WINDOW_CYCLES`
  - number of reference-clock cycles in one measurement window
  - legal range: `WINDOW_CYCLES >= 1`
- `CONTINUOUS_MODE`
  - `1` automatically restarts a new measurement window whenever `enable` is high and the meter is idle
  - `0` requires an explicit `start` request while idle
  - legal values: `0` or `1`
- `RANGE_CHECK_EN`
  - enables output threshold comparison against `min_acceptable_count` and `max_acceptable_count`
  - legal values: `0` or `1`
- `AVERAGING_EN`
  - enables exponential moving-average smoothing on `average_count`
  - legal values: `0` or `1`
- `AVERAGE_SHIFT`
  - shift amount used for the exponential moving average when averaging is enabled
  - legal range: `AVERAGE_SHIFT >= 1`

## Ports

- `ref_clk`
  - trusted reference clock used to define the measurement window
- `rst_n`
  - active-low reset
- `enable`
  - master enable for the measurement engine
- `start`
  - one-shot start request when `CONTINUOUS_MODE = 0`
- `measured_clk`
  - clock being measured
- `min_acceptable_count`
  - low threshold for range checking when enabled
- `max_acceptable_count`
  - high threshold for range checking when enabled
- `measured_count`
  - last completed sample count
- `average_count`
  - smoothed count when averaging is enabled, or a copy of `measured_count` otherwise
- `result_valid`
  - latched indication that the outputs contain a completed sample while enabled
- `sample_valid`
  - one-cycle pulse when a measurement window completes
- `busy`
  - asserted while a measurement window is in progress
- `below_range`
  - indicates the completed sample was below `min_acceptable_count`
- `above_range`
  - indicates the completed sample was above `max_acceptable_count`
- `out_of_range`
  - convenience OR of `below_range` and `above_range`

## Behavioral Contract

- The measured clock is observed through a free-running binary counter in the measured-clock domain.
- That counter is converted to Gray code, synchronized into the reference-clock domain, and converted back to binary before window snapshots are taken.
- `measured_count` represents the synchronized edge-count delta between the start and end of the completed reference window, not an instantaneous frequency estimate.
- In one-shot mode, `start` is only accepted while idle and enabled.
- In continuous mode, a new window automatically begins on the first idle cycle while enabled.
- `result_valid` clears when `enable` deasserts.

## Current Implementation Notes

- This baseline intentionally exposes a quantitative windowed count rather than trying to report a scaled Hertz value.
- The observable measurement includes the synchronizer convention of the Gray-coded counter path, so the number corresponds to synchronized edge history over the window.
- After an abrupt measured-clock rate change, the first continuous sample can be transitional before later windows settle to the new steady-state count.
- Averaging is implemented as an exponential moving average rather than a finite boxcar average.
- The measured counter free-runs whenever `measured_clk` is active and reset is released, regardless of `enable`.

## Illegal Configurations

- `COUNTER_WIDTH < 1`
- `WINDOW_CYCLES < 1`
- `CONTINUOUS_MODE` not in `{0, 1}`
- `RANGE_CHECK_EN` not in `{0, 1}`
- `AVERAGING_EN` not in `{0, 1}`
- `AVERAGE_SHIFT < 1`

## Planned Future Expansion

- calibrated fixed-point frequency output derived from the reference timebase
- programmable measurement-window length at runtime
- multi-sample boxcar averaging modes
- explicit stale-clock or no-edge status outputs separate from threshold range checks
