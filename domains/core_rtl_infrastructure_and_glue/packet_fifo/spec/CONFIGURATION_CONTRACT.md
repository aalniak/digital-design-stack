# Packet FIFO Configuration Contract

## Implemented Configuration Surface

The current `packet_fifo` implementation provides a packet-aware same-clock elasticity primitive with the following parameter set:

- `DATA_WIDTH`
  - payload width on the ingress and egress stream
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `META_WIDTH`
  - optional packet-associated beat metadata width stored with each beat
  - legal range in the current implementation: `META_WIDTH >= 0`
- `DEPTH`
  - beat storage depth of the underlying queue
  - legal range in the current implementation: `DEPTH >= 1`
- `ALMOST_FULL_THRESHOLD`
  - beat-occupancy watermark for `almost_full`
- `ALMOST_EMPTY_THRESHOLD`
  - beat-occupancy watermark for `almost_empty`
- `COUNT_EN`
  - `1` exposes the current beat count on `beat_occupancy`
  - `0` keeps a stable port set and drives `beat_occupancy` to zero
- `PACKET_COUNT_EN`
  - `1` exposes the current complete-packet count on `packet_occupancy`
  - `0` keeps a stable port set and drives `packet_occupancy` to zero

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`, `s_meta`, `s_first`, `s_last`
  - ingress ready-valid channel with explicit packet-boundary flags
- `m_valid`, `m_ready`, `m_data`, `m_meta`, `m_first`, `m_last`
  - egress ready-valid channel with preserved packet-boundary flags
- `full`, `empty`, `almost_full`, `almost_empty`
  - beat-level queue status inherited from the underlying stream FIFO
- `beat_occupancy`
  - current beat count when enabled
- `packet_occupancy`
  - current count of complete packets buffered when enabled
- `overflow`
  - one-cycle pulse when an ingress transfer is attempted while no slot is available

## Behavioral Contract

- The module is same-clock only and is not a CDC primitive.
- Beat order, metadata, and `first` and `last` flags are preserved exactly.
- `packet_occupancy` counts complete packets currently buffered, meaning packets whose `last` beat has entered the FIFO and whose `last` beat has not yet exited.
- A partially buffered packet that has not yet reached `s_last` does not contribute to `packet_occupancy` in the current implementation.
- Overflow handling is backpressure-based and never drops accepted beats.

## Current Implementation Notes

- The first implementation reuses `stream_fifo` as the storage engine and adds packet counting around it.
- Packet semantics are preserved by storing `first` and `last` alongside payload and metadata on every beat.
- The current baseline does not enforce semantic correctness of `s_first` and `s_last`; it preserves what the source provides.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `META_WIDTH < 0`
- `DEPTH < 1`
- `COUNT_EN` not in `{0, 1}`
- `PACKET_COUNT_EN` not in `{0, 1}`

## Planned Future Expansion

- optional malformed-packet detection for illegal `first` and `last` sequences
- optional complete-packet admission policy for drop-or-stall behavior on incomplete packets
- optional packet-drop diagnostics and packet-truncation guards
- broader parameter sweeps and stronger packet-structure formal checks
