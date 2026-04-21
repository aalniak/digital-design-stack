# Stream FIFO Configuration Contract

## Implemented Configuration Surface

The current `stream_fifo` implementation provides a reusable same-clock elasticity primitive with the following parameter set:

- `DATA_WIDTH`
  - payload width on the ingress and egress stream
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `SIDEBAND_WIDTH`
  - optional beat-aligned metadata width that is stored and replayed with the payload
  - legal range in the current implementation: `SIDEBAND_WIDTH >= 0`
- `DEPTH`
  - number of beats stored in the circular buffer
  - legal range in the current implementation: `DEPTH >= 1`
- `ALMOST_FULL_THRESHOLD`
  - level at or above which `almost_full` asserts
  - legal range in the current implementation: `0 <= ALMOST_FULL_THRESHOLD <= DEPTH`
- `ALMOST_EMPTY_THRESHOLD`
  - level at or below which `almost_empty` asserts
  - legal range in the current implementation: `0 <= ALMOST_EMPTY_THRESHOLD <= DEPTH`
- `OUTPUT_REG`
  - reserved configuration hook for future output-register variants
  - legal range in the current implementation: `OUTPUT_REG = 0` only
- `COUNT_EN`
  - `1` exposes the true occupancy count on `occupancy`
  - `0` keeps a stable port set and drives `occupancy` to zero

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`, `s_sideband`
  - ingress ready-valid channel
- `m_valid`, `m_ready`, `m_data`, `m_sideband`
  - egress ready-valid channel
- `full`
  - current storage-full indication
- `empty`
  - current storage-empty indication
- `almost_full`
  - watermark indication derived from the current occupancy level
- `almost_empty`
  - watermark indication derived from the current occupancy level
- `occupancy`
  - current beat count when enabled, otherwise zero
- `overflow`
  - one-cycle pulse when an ingress transfer is attempted while no slot is available

## Behavioral Contract

- The module is a single-clock FIFO and is not a CDC primitive.
- Payload and sideband information move together and are never reordered.
- A push occurs when `s_valid && s_ready`.
- A pop occurs when `m_valid && m_ready`.
- The implementation allows a same-cycle replacement transfer when the FIFO is full and the consumer accepts a beat in that cycle.
- `overflow` is a pulse, not a sticky flag.
- Current status outputs reflect the visible stored occupancy after the most recent clock edge.

## Current Implementation Notes

- The first implementation is a circular buffer with exact occupancy tracking.
- The current RTL intentionally implements the unregistered output mode only.
- The stored beat at the read pointer is presented directly on the output interface while `m_valid` indicates whether that beat is meaningful.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `SIDEBAND_WIDTH < 0`
- `DEPTH < 1`
- `ALMOST_FULL_THRESHOLD` outside `0..DEPTH`
- `ALMOST_EMPTY_THRESHOLD` outside `0..DEPTH`
- `OUTPUT_REG != 0`
- `COUNT_EN` not in `{0, 1}`

## Planned Future Expansion

- registered-output mode without changing the public contract style
- optional first-word-fall-through variant selection
- optional underflow pulse for explicit consumer misuse reporting
- automated parameter sweeps across additional depth and sideband combinations
