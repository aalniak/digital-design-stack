# Skid Buffer Configuration Contract

## Implemented Configuration Surface

The current `skid_buffer` implementation provides a reusable late-stall capture primitive for valid-ready channels with the following parameter set:

- `DATA_WIDTH`
  - payload width carried through the skid family
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `SIDEBAND_WIDTH`
  - width of the sideband bundle carried alongside payload
  - legal range in the current implementation: `SIDEBAND_WIDTH >= 0`
- `DEPTH`
  - number of chained single-entry skid stages
  - legal range in the current implementation: `DEPTH >= 0`
  - `DEPTH = 0` gives a direct pass-through path

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`
  - source-side valid input
- `s_ready`
  - source-side ready output
- `s_data`
  - source-side payload input
- `s_sideband`
  - source-side sideband input
- `m_valid`
  - destination-side valid output
- `m_ready`
  - destination-side ready input
- `m_data`
  - destination-side payload output
- `m_sideband`
  - destination-side sideband output

## Behavioral Contract

- The public protocol is lossless valid-ready transport.
- All payload and sideband bits for a beat advance together.
- `DEPTH = 0` behaves as a direct combinational pass-through.
- `DEPTH > 0` provides one spare beat of elasticity per chained skid stage.
- The first late-stall beat is captured instead of dropped.
- When a stored beat is waiting at the output with `m_valid = 1` and `m_ready = 0`, the visible output beat remains stable until accepted.
- Reset clears all stored beats in the skid chain.
- The current reset contract assumes upstream logic deasserts `s_valid` while reset is active.

## Current Implementation Notes

- The current baseline is built from chained one-entry skid stages.
- The empty path for `DEPTH > 0` remains combinational through the stage chain in this first implementation.
- The first-pass family focuses on correctness of late-stall capture, ordering, and sideband alignment.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `SIDEBAND_WIDTH < 0`
- `DEPTH < 0`

## Planned Future Expansion

- explicit `REGISTER_READY` mode selection
- explicit `LOW_LATENCY_MODE` versus more strongly registered variants
- occupancy visibility for debug and performance counters
- wrapper variants aligned with named stream or packet profiles
