# Clock Mux Controller Configuration Contract

## Implemented Configuration Surface

The current `clock_mux_controller` baseline provides policy control for clock-source selection with the following parameter set:

- `NUM_SOURCES`
  - number of managed source choices
  - legal range: `NUM_SOURCES >= 2`
- `DEFAULT_SOURCE`
  - startup source selection after reset
  - legal range: `0 <= DEFAULT_SOURCE < NUM_SOURCES`
- `WAIT_FOR_STABLE_EN`
  - requires the target source to remain healthy for `STABLE_CYCLES` before switching
  - legal values: `0` or `1`
- `STABLE_CYCLES`
  - consecutive healthy cycles required before committing a switch when waiting is enabled
  - legal range: `STABLE_CYCLES >= 1`
- `AUTO_FAILOVER_EN`
  - enables automatic failover from an unhealthy active source to the lowest-index healthy alternate source
  - legal values: `0` or `1`
- `HOLD_CYCLES`
  - number of post-switch cycles during which `switch_in_progress` and `hold_request` remain asserted
  - legal range: `HOLD_CYCLES >= 0`
- `STATUS_STICKY_EN`
  - enables sticky retention of fault and auto-failover history
  - legal values: `0` or `1`

## Ports

- `clk`
  - controller clock
- `rst_n`
  - active-low reset
- `request_valid`
  - manual source-request qualifier
- `requested_source`
  - requested source index for manual switching
- `source_healthy`
  - health indications for each managed source
- `inhibit_switch`
  - prevents a manual request from being accepted
- `clear_sticky`
  - clears sticky status outputs when sticky mode is enabled
- `mux_select`
  - source-select output for the downstream switch fabric
- `active_source`
  - currently selected source according to the controller policy
- `pending_source`
  - target source currently waiting for stable qualification
- `pending_source_valid`
  - indicates a pending switch candidate is being tracked
- `switch_in_progress`
  - asserted during the configured post-switch hold window
- `hold_request`
  - convenience copy of `switch_in_progress` for reset or gating coordination
- `active_source_healthy`
  - reset-quiet indication that the active source is currently healthy
- `request_reject_pulse`
  - one-cycle pulse when a manual request is invalid or inhibited
- `switch_done_pulse`
  - one-cycle pulse when the controller commits to a source change
- `auto_failover_pulse`
  - one-cycle pulse when the committed change came from automatic failover
- `fault_status`
  - live or sticky fault indication when the active source is unhealthy and no failover source is available
- `auto_failover_status`
  - live or sticky indication that automatic failover has occurred

## Behavioral Contract

- `mux_select` and `active_source` are the same in this baseline. The controller assumes the downstream switch fabric uses that selection directly.
- Manual requests are level-sensitive. If `WAIT_FOR_STABLE_EN = 1`, the request must remain presented until the target has been healthy for `STABLE_CYCLES` and the switch commits.
- Automatic failover only occurs when the active source is unhealthy and a healthy alternate source exists.
- The current auto-failover policy chooses the lowest-index healthy alternate source.
- `switch_in_progress` and `hold_request` represent a post-switch coordination window, not the analog or physical edge-level handoff inside the downstream switch fabric.
- `pending_source_valid` shows that a source candidate is being tracked for possible switch commit.

## Current Implementation Notes

- The controller owns policy only. It does not try to create glitchless clock handoff behavior itself.
- The baseline keeps request arbitration simple: manual requests have priority over automatic failover.
- `fault_status` is reset-quiet and only becomes meaningful after the controller leaves reset.
- When sticky mode is disabled, `fault_status` behaves as a live policy fault flag and `auto_failover_status` mirrors the most recent pulse behavior.

## Illegal Configurations

- `NUM_SOURCES < 2`
- `DEFAULT_SOURCE` outside the supported source range
- `WAIT_FOR_STABLE_EN` not in `{0, 1}`
- `STABLE_CYCLES < 1`
- `AUTO_FAILOVER_EN` not in `{0, 1}`
- `HOLD_CYCLES < 0`
- `STATUS_STICKY_EN` not in `{0, 1}`

## Planned Future Expansion

- explicit downstream switch-acknowledge handshake
- programmable failover priority tables instead of fixed lowest-index selection
- separate pre-switch wait state and post-switch settle state reporting
- tighter coordination hooks for reset release and clock gating around a transition
