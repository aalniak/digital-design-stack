# Gearbox Configuration Contract

## Implemented Configuration Surface

The current `gearbox` baseline is a same-clock symbol repacker with the following parameter set:

- `SYMBOL_WIDTH`
  - width of one logical symbol
  - legal range in the current implementation: `SYMBOL_WIDTH >= 1`
- `IN_SYMBOLS`
  - maximum symbols presented on each ingress beat
  - legal range in the current implementation: `IN_SYMBOLS >= 1`
- `OUT_SYMBOLS`
  - maximum symbols presented on each egress beat
  - legal range in the current implementation: `OUT_SYMBOLS >= 1`
- `LAST_EN`
  - `1` enables packet-boundary handling through `s_last` and `m_last`
  - `0` ignores `s_last` and keeps `m_last` low unless future wrappers add other semantics
- `FLUSH_EN`
  - `1` enables the explicit `flush` input
  - `0` ignores `flush`

## Ports

- `clk`
  - local synchronous clock
- `rst_n`
  - active-low reset
- `s_valid`, `s_ready`, `s_data`, `s_keep`, `s_last`
  - ingress ready-valid channel with symbol-valid mask and optional packet boundary
- `flush`
  - explicit request to drain a partially filled aggregate
- `m_valid`, `m_ready`, `m_data`, `m_keep`, `m_last`
  - egress ready-valid channel with normalized compacted symbol packing
- `busy`
  - indicates internal state is holding buffered or pending output symbols

## Behavioral Contract

- Symbols are emitted in ingress lane order, with compacted low-lane packing on output.
- `s_keep` may be sparse in the current implementation. The module compacts asserted ingress symbols into contiguous low output lanes.
- When `OUT_SYMBOLS >= IN_SYMBOLS`, the module accumulates ingress symbols until it can emit a full output beat, or until `s_last` or `flush` forces an early drain.
- When a widening configuration already holds partial state and the next ingress beat would overflow the current output group, the module emits the buffered partial group first with `m_last = 0`, then accepts the new ingress beat on a following cycle.
- When `OUT_SYMBOLS < IN_SYMBOLS`, one accepted ingress beat is compacted and then sliced into one or more egress beats.
- `m_keep` always reflects the number of valid output symbols on the current egress beat.

## Current Implementation Notes

- The current baseline is same-clock only.
- The widening path is correctness-first and may insert a bubble when it has to drain a partial group before accepting the next ingress beat.
- A standalone `flush` only drains buffered partial state in the widening path. In the narrowing path, `flush` is only meaningful when sampled with an accepted ingress beat.
- Zero-symbol ingress beats are ignored in the current implementation. There is no dedicated representation for zero-length packets yet.

## Illegal Configurations

- `SYMBOL_WIDTH < 1`
- `IN_SYMBOLS < 1`
- `OUT_SYMBOLS < 1`
- `LAST_EN` not in `{0, 1}`
- `FLUSH_EN` not in `{0, 1}`

## Planned Future Expansion

- wrapper profiles for byte-stream, word-stream, and packet-stream naming conventions
- optional output register or skid-assisted variants for timing relief
- richer status outputs, including buffered-symbol count and overflow diagnostics
- deeper packet-boundary assertions and randomized ratio sweeps
