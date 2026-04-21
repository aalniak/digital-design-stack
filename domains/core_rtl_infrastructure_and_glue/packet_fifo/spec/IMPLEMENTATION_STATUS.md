# Packet FIFO Implementation Status

## Current Status

`packet_fifo` is implemented and verified as the baseline same-clock packet-aware buffering primitive for the core library.

The current implementation supports:

- configurable payload width through `DATA_WIDTH`
- configurable per-beat metadata through `META_WIDTH`
- explicit `first` and `last` preservation on every beat
- beat occupancy through the wrapped `stream_fifo`
- complete-packet occupancy tracking through `packet_occupancy`
- same backpressure and overflow semantics as the underlying `stream_fifo`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation with directed partial-packet and complete-packet occupancy checks
- randomized simulation with beat-order and boundary scoreboard checks
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_packet_fifo_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The module reuses `stream_fifo` rather than duplicating queue logic.
- `packet_occupancy` counts complete packets only, not all in-flight partial packets.
- Packet flags are preserved exactly as supplied; malformed source framing is not corrected.
- Overflow is handled through backpressure only.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- malformed-packet detection and reporting
- whole-packet drop policies for overflow-sensitive systems
- stronger sequential formal proofs for complete-packet accounting
- wrapper variants with richer packet metadata conventions

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Strengthen packet semantics
   - add malformed-packet detection and optional assertions on illegal `first` and `last` sequences
   - add optional whole-packet acceptance or truncation guards

2. Expand verification breadth
   - sweep more packet-length and depth combinations
   - add sequential formal checks for packet-count evolution

3. Grow the wrapper family
   - define standard packet-sideband conventions for higher-level packetizer and depacketizer flows
