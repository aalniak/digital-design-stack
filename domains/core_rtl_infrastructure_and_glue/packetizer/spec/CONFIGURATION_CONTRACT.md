# Packetizer Configuration Contract

## Implemented Configuration Surface

The current `packetizer` baseline provides a registered packet-normalization stage with the following parameter set:

- `DATA_WIDTH`
  - payload and framed beat width
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `TYPE_WIDTH`
  - packet type field width
  - legal range in the current implementation: `TYPE_WIDTH >= 1`
- `LENGTH_WIDTH`
  - packet length field width
  - legal range in the current implementation: `LENGTH_WIDTH >= 1`
- `HEADER_MODE`
  - `0` selects sideband-only framing
  - `1` emits one synthetic header beat before the payload
- `AUTO_CLOSE_EN`
  - `0` treats an unexpected restart with `s_first = 1` during an open packet as a protocol error
  - `1` allows that restart and treats it as an implicit packet boundary
- `TRAILER_EN`
  - present for future extensibility
  - legal value in the current implementation: `0` only

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`
  - ingress ready-valid payload channel
- `s_first`, `s_last`
  - ingress packet-boundary hints from the local producer
- `s_type`, `s_length`, `s_error`
  - per-packet metadata sampled at packet start
- `m_valid`, `m_ready`, `m_data`
  - framed egress ready-valid channel
- `m_first`, `m_last`
  - normalized packet boundary flags on the egress channel
- `m_header`
  - identifies the synthetic header beat when `HEADER_MODE = 1`
- `m_type`, `m_length`, `m_error`
  - packet metadata carried alongside the framed output
- `protocol_error`
  - sticky sequencing-error indicator
- `busy`
  - indicates the module is holding output, a staged first payload beat, or an open packet context

## Behavioral Contract

- The ingress interface is packet-aware. `s_first` should mark the first payload beat of a packet and `s_last` should mark the final payload beat.
- When `HEADER_MODE = 0`, payload beats are emitted directly with normalized sidebands.
- When `HEADER_MODE = 1`, the first accepted payload beat of a packet is staged internally while a synthetic header beat is emitted first.
- Header data is encoded with `s_length` in the low bits, `s_type` above it, and `s_error` above both fields.
- Packet metadata is captured from the accepted packet-start beat and reused for later payload beats in the same packet.
- `protocol_error` is sticky and currently only clears on reset.

## Current Implementation Notes

- The current design is same-clock only.
- The first-pass implementation is fully registered and favors observability over minimum latency.
- In header mode, the first payload beat is buffered internally, so `s_ready` is deasserted until that held beat has been transferred into the output path.
- A missing `s_first` at packet start is tolerated functionally, but it sets `protocol_error`.
- `AUTO_CLOSE_EN` currently only changes how an unexpected new `s_first` during an open packet is classified. No trailer beat is generated.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `TYPE_WIDTH < 1`
- `LENGTH_WIDTH < 1`
- `HEADER_MODE` not in `{0, 1}`
- `AUTO_CLOSE_EN` not in `{0, 1}`
- `TRAILER_EN != 0`
- `HEADER_MODE = 1` with `DATA_WIDTH < TYPE_WIDTH + LENGTH_WIDTH + 1`

## Planned Future Expansion

- optional trailer emission with integrity or checksum fields
- deeper buffering for no-bubble header insertion
- packet abort and explicit drop policies
- richer protocol diagnostics and counters
