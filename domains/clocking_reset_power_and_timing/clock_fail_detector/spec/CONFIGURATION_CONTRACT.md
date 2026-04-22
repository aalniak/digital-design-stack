# Clock Fail Detector Configuration Contract

## Implemented Configuration Surface

The current `clock_fail_detector` baseline provides reference-domain clock-health supervision with the following parameter set:

- `WINDOW_CYCLES`
  - number of reference-clock cycles in one edge-count observation window
  - legal range in the current implementation: `WINDOW_CYCLES >= 1`
- `TIMEOUT_CYCLES`
  - maximum allowed reference-clock gap without a monitored edge before timeout violation
  - legal range in the current implementation: `TIMEOUT_CYCLES >= 1`
- `MIN_EDGES`
  - minimum monitored-edge count required per window
  - legal range in the current implementation: `MIN_EDGES >= 0`
- `MAX_EDGES`
  - maximum monitored-edge count allowed per window
  - legal range in the current implementation: `MAX_EDGES >= MIN_EDGES`
- `FILTER_DEPTH`
  - number of consecutive bad samples required before asserting fault
  - legal range in the current implementation: `FILTER_DEPTH >= 1`
- `STICKY_FAULT_EN`
  - `1` keeps `fault` asserted until `clear_fault` or reset
  - `0` allows the fault output to clear under automatic recovery rules
- `AUTO_RECOVER_EN`
  - `1` allows non-sticky faults to clear after healthy activity resumes
  - `0` keeps non-sticky faults asserted until `clear_fault` or reset

## Ports

- `ref_clk`
  - trusted reference clock used for supervision
- `rst_n`
  - active-low reset
- `enable`
  - enables monitoring and activity qualification
- `mon_clk`
  - monitored clock input
- `clear_fault`
  - explicit fault clear request
- `fault`
  - aggregated health-fault indication
- `healthy`
  - convenience inverse health signal while enabled and out of reset
- `timeout_event`
  - one-cycle pulse when timeout threshold is first crossed
- `window_event`
  - one-cycle pulse when a window closes with edge count outside the accepted range
- `monitored_edge_pulse`
  - synchronized indication that a monitored clock edge was observed in the reference domain
- `window_edge_count`
  - current in-progress window edge count

## Behavioral Contract

- The detector samples monitored activity into the reference domain by synchronizing a toggle that flips on each monitored positive edge while monitoring is enabled.
- Timeout supervision counts reference-clock cycles since the last synchronized monitored edge.
- Window supervision counts synchronized monitored edges inside each `WINDOW_CYCLES` reference-cycle window.
- `fault` asserts when timeout or window violations persist long enough to satisfy `FILTER_DEPTH`.
- `timeout_event` and `window_event` are pulse-style event indicators, while `fault` is the persistent health output.
- `healthy` is forced low during active reset so the public interface stays quiet until supervision is actually running.

## Current Implementation Notes

- This baseline assumes the monitored positive-edge rate is low enough that the reference-domain toggle synchronizer can observe each edge. It is intended for supervision and failover policy, not for high-accuracy frequency metrology.
- `window_edge_count` reports the in-progress count for the current window and resets when the window rolls over.
- If monitoring is disabled, internal observation state resets. Sticky faults remain asserted unless explicitly cleared.
- Automatic recovery only clears faults when `STICKY_FAULT_EN = 0` and `AUTO_RECOVER_EN = 1`.

## Illegal Configurations

- `WINDOW_CYCLES < 1`
- `TIMEOUT_CYCLES < 1`
- `MIN_EDGES < 0`
- `MAX_EDGES < MIN_EDGES`
- `FILTER_DEPTH < 1`
- `STICKY_FAULT_EN` not in `{0, 1}`
- `AUTO_RECOVER_EN` not in `{0, 1}`

## Planned Future Expansion

- higher-fidelity frequency supervision using synchronized counters instead of a toggle sampler
- explicit hysteresis between fail and recover thresholds
- richer status outputs with separate sticky timeout and window-fault causes
- wrapper profiles for failover and reset-policy integration
