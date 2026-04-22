# Width Converter Configuration Contract

## Implemented Configuration Surface

The current `width_converter` implementation provides a byte-oriented same-clock width-adaptation primitive with the following parameter set:

- `IN_BYTES`
  - number of payload bytes on the ingress stream
  - legal range in the current implementation: `IN_BYTES >= 1`
- `OUT_BYTES`
  - number of payload bytes on the egress stream
  - legal range in the current implementation: `OUT_BYTES >= 1`

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`, `s_keep`, `s_last`
  - ingress ready-valid channel with byte-valid mask and end-of-packet flag
- `m_valid`, `m_ready`, `m_data`, `m_keep`, `m_last`
  - egress ready-valid channel with byte-valid mask and end-of-packet flag
- `busy`
  - indicates the converter is holding partial or staged state internally

## Behavioral Contract

- The module is same-clock only and is not a CDC primitive.
- Width adaptation is supported only when one side is an integer byte multiple of the other.
- Byte lane ordering is low-byte-first: earlier ingress bytes occupy lower-order output lanes during widening, and lower-order source lanes exit first during narrowing.
- `s_keep` and `m_keep` describe valid byte lanes.
- `s_last` is preserved and re-timed to the final emitted beat of the corresponding packet fragment.
- The baseline implementation uses internal staging, so it does not promise bubble-free ratio-boundary throughput.

## Current Implementation Notes

- `IN_BYTES == OUT_BYTES` uses a direct pass-through datapath.
- Widening accumulates several ingress beats before presenting one output beat.
- Narrowing stores one ingress beat and emits slices over several output beats.
- The current narrowing implementation assumes partial final words use a keep mask that is contiguous from the low byte lanes.

## Illegal Configurations

- `IN_BYTES < 1`
- `OUT_BYTES < 1`
- narrowing with `IN_BYTES % OUT_BYTES != 0`
- widening with `OUT_BYTES % IN_BYTES != 0`

## Planned Future Expansion

- optional stall-free ratio-boundary variants
- optional registered-output or skid-assisted wrappers
- stronger malformed-keep detection for non-contiguous partial words
- packet-sideband expansion beyond `last`
