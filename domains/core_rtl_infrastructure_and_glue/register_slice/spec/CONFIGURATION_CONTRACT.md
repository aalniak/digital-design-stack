# Register Slice Configuration Contract

## Implemented Configuration Surface

The current `register_slice` implementation provides a reusable valid-ready timing-relief primitive with the following parameter set:

- `DATA_WIDTH`
  - payload width carried through the slice
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `SIDEBAND_WIDTH`
  - width of the sideband bundle pipelined alongside the payload
  - legal range in the current implementation: `SIDEBAND_WIDTH >= 0`
- `STAGES`
  - number of elastic pipeline stages
  - legal range in the current implementation: `STAGES >= 0`
  - `STAGES = 0` gives a direct bypass path

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
- `STAGES = 0` behaves as a direct combinational pass-through.
- `STAGES > 0` inserts elastic register stages while preserving ordering.
- When the output is stalled with `m_valid = 1` and `m_ready = 0`, the visible output beat remains stable until accepted.
- Reset clears stored valid state in all registered stages.

## Current Implementation Notes

- The current RTL implements a simple elastic slice family rather than a larger mode matrix.
- The first-pass family focuses on transport correctness, sideband alignment, and configurability through stage count.
- Reverse-path ready remains combinational across the configured stage chain in this first implementation.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `SIDEBAND_WIDTH < 0`
- `STAGES < 0`

## Planned Future Expansion

- explicit mode split for forward-only and fully-registered handshake families
- occupancy status outputs
- optional low-power zeroing behavior for invalid payload storage
- wrapper variants aligned with named bus or stream profiles
