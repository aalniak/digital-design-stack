# Depacketizer Configuration Contract

## Implemented Configuration Surface

The current `depacketizer` baseline provides a registered packet-unpacking stage with the following parameter set:

- `DATA_WIDTH`
  - framed beat width and payload beat width
  - legal range in the current implementation: `DATA_WIDTH >= 1`
- `TYPE_WIDTH`
  - packet type field width
  - legal range in the current implementation: `TYPE_WIDTH >= 1`
- `LENGTH_WIDTH`
  - packet length field width
  - legal range in the current implementation: `LENGTH_WIDTH >= 1`
- `HEADER_MODE`
  - `0` selects sideband-only packet parsing
  - `1` expects a synthetic header beat ahead of payload beats
- `DROP_BAD_PACKET`
  - `0` forwards malformed or error-marked payload while still flagging `protocol_error`
  - `1` suppresses payload beats from malformed or error-marked packets

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`
  - ingress ready-valid framed channel
- `s_first`, `s_last`, `s_header`
  - ingress framing hints
- `s_type`, `s_length`, `s_error`
  - ingress metadata sidebands
- `m_valid`, `m_ready`, `m_data`
  - payload-only egress ready-valid channel
- `m_first`, `m_last`
  - normalized packet boundaries on the payload output
- `m_type`, `m_length`, `m_error`
  - decoded packet metadata attached to each payload beat
- `protocol_error`
  - sticky malformed-sequence indicator
- `dropping_packet`
  - indicates the current packet is being suppressed because bad-packet drop policy is active
- `busy`
  - indicates an output beat is pending or a packet context is currently open

## Behavioral Contract

- In sideband mode, the first payload beat of a packet should assert `s_first`, and no beat should assert `s_header`.
- In header mode, the first ingress beat of a packet must be a header beat with `s_header = 1`, `s_first = 1`, and `s_last = 0`.
- Header mode decodes packet metadata from `s_data`, using low bits for length, upper header bits for type, and the next bit for error.
- In header mode, the redundant sideband metadata on the header beat is checked against the encoded header data and mismatches raise `protocol_error`.
- The first payload beat after a decoded header is re-labeled with `m_first = 1` even though the header beat consumed the ingress `s_first`.
- `protocol_error` is sticky and only clears on reset.

## Current Implementation Notes

- The current design is same-clock only.
- The baseline is intentionally registered and correctness-first.
- When `DROP_BAD_PACKET = 1`, packets flagged with metadata error or malformed framing are suppressed from the payload output until packet close.
- Header mode currently assumes at least one payload beat follows each header. A header beat with `s_last = 1` is treated as malformed.
- Metadata continuity is checked on continuation payload beats in both sideband mode and header mode.

## Illegal Configurations

- `DATA_WIDTH < 1`
- `TYPE_WIDTH < 1`
- `LENGTH_WIDTH < 1`
- `HEADER_MODE` not in `{0, 1}`
- `DROP_BAD_PACKET` not in `{0, 1}`
- `HEADER_MODE = 1` with `DATA_WIDTH < TYPE_WIDTH + LENGTH_WIDTH + 1`

## Planned Future Expansion

- richer malformed-packet accounting beyond one sticky status bit
- explicit abort and truncate policies
- buffering for header-plus-first-payload lookahead
- configurable header field layouts and optional trailers
