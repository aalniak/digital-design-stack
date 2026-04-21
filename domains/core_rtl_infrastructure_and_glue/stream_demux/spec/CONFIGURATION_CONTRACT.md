# Stream Demux Configuration Contract

## Implemented Configuration Surface

The current `stream_demux` implementation provides a route-selectable same-clock steering primitive with the following parameter set:

- `DATA_WIDTH`
  - payload width on the ingress and egress stream
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `SIDEBAND_WIDTH`
  - optional beat-aligned metadata width preserved across routing
  - legal range in the current implementation: `SIDEBAND_WIDTH >= 0`
- `NUM_OUTPUTS`
  - number of output streams
  - legal range in the current implementation: `NUM_OUTPUTS >= 1`
- `HOLD_ROUTE_UNTIL_LAST`
  - `1` latches the selected output on the first accepted beat of a packet and keeps it until the accepted `last` beat
  - `0` allows route selection to vary every accepted beat
- `DROP_ON_INVALID`
  - `1` accepts and drops invalid-route beats while asserting `invalid_route`
  - `0` stalls invalid-route beats until the source changes or withdraws them

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`, `s_sideband`, `s_last`, `s_select`
  - ingress ready-valid channel plus route select and packet-end indication
- `m_valid`, `m_ready`, `m_data`, `m_sideband`, `m_last`
  - output vector of routed streams
- `invalid_route`
  - indicates an invalid route selection on the current source beat
- `held_route_active`
  - indicates that packet-hold mode has latched a route
- `held_route_select`
  - latched route value while packet-hold mode is active

## Behavioral Contract

- The module has no internal payload buffering in the current implementation.
- Only the selected output sees `m_valid = 1` for a valid route.
- Only the selected output's `m_ready` contributes to `s_ready` for a valid route.
- When `HOLD_ROUTE_UNTIL_LAST = 1`, the first accepted beat with `s_last = 0` latches the route until an accepted beat with `s_last = 1` clears the hold.
- When `DROP_ON_INVALID = 1`, invalid-route beats are consumed and dropped without asserting any output valid.
- When `DROP_ON_INVALID = 0`, invalid-route beats are backpressured.

## Current Implementation Notes

- The current baseline is same-clock only and intentionally non-buffered.
- `s_last` defines the packet boundary for held routing.
- The module preserves whatever `s_sideband` and `s_last` values the source provides; it does not reinterpret them.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `SIDEBAND_WIDTH < 0`
- `NUM_OUTPUTS < 1`
- `HOLD_ROUTE_UNTIL_LAST` not in `{0, 1}`
- `DROP_ON_INVALID` not in `{0, 1}`

## Planned Future Expansion

- optional internal skid buffering for large-fanout timing relief
- optional `first` support for stronger packet-state checking
- optional decode-error counters and invalid-route statistics
- broader formal checks for held-route transitions and invalid-route policy
