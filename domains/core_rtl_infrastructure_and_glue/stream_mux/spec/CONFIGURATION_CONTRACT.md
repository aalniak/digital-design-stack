# Stream Mux Configuration Contract

## Implemented Configuration Surface

The current `stream_mux` implementation provides a same-clock fan-in primitive with the following parameter set:

- `NUM_INPUTS`
  - number of ingress streams
  - legal range in the current implementation: `NUM_INPUTS >= 1`
- `DATA_WIDTH`
  - payload width on every ingress stream and the egress stream
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `SIDEBAND_WIDTH`
  - optional beat-aligned metadata width preserved from the granted input
  - legal range in the current implementation: `SIDEBAND_WIDTH >= 0`
- `ARBITRATION_MODE`
  - `0` selects low-index-high-priority arbitration
  - `1` selects round-robin arbitration
- `HOLD_UNTIL_LAST`
  - `1` keeps the granted input selected until an accepted beat with `last = 1`
  - `0` arbitrates every accepted beat independently
- `SOURCE_ID_EN`
  - `1` exposes the selected input index on `m_source_id`
  - `0` keeps a stable port set and drives `m_source_id` to zero

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`, `s_sideband`, `s_last`
  - vectorized ingress ready-valid channels
- `m_valid`, `m_ready`, `m_data`, `m_sideband`, `m_last`
  - single egress ready-valid channel
- `m_source_id`
  - selected ingress index when enabled
- `held_grant_active`
  - indicates packet-hold mode is currently pinning the grant
- `held_grant_id`
  - held ingress index while packet-hold mode is active

## Behavioral Contract

- The module has no internal payload buffering in the current implementation.
- Only one ingress is selected at a time.
- Only the selected ingress sees `ready = m_ready`; all other ingress channels see `ready = 0`.
- In round-robin mode, the pointer advances after each accepted beat when beat-level arbitration is active, or after the accepted final beat of a held packet when packet-hold mode is enabled.
- In hold mode, the first accepted non-final beat latches the winner until an accepted `last` beat from that same input clears the hold.

## Current Implementation Notes

- The baseline implementation trusts the source to keep a held packet source valid until its `last` beat is accepted.
- Reset forces a quiet external interface and clears all held-grant state.
- The first implementation keeps arbitration internal rather than requiring external arbiter submodules.

## Illegal Configurations

- `NUM_INPUTS < 1`
- `DATA_WIDTH < 1`
- `SIDEBAND_WIDTH < 0`
- `ARBITRATION_MODE` not in `{0, 1}`
- `HOLD_UNTIL_LAST` not in `{0, 1}`
- `SOURCE_ID_EN` not in `{0, 1}`

## Planned Future Expansion

- optional buffered or pipelined arbitration wrappers
- external grant-override mode for software-controlled selection
- richer diagnostics for held-source contract violations
- stronger packet-aware formal checks
