# Depacketizer Implementation Status

## Current Status

`depacketizer` is implemented as the first normalized packet-unpacking block that pairs cleanly with the current `packetizer` baseline.

The current implementation supports:

- sideband-only packet parsing
- synthetic-header parsing
- sticky `protocol_error` reporting
- metadata continuity checks on continuation beats
- optional bad-packet suppression through `DROP_BAD_PACKET`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for sideband parsing, sticky sequencing error behavior, header parsing, metadata decode checking, and bad-packet drop policy
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_depacketizer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- Header mode decodes metadata from header data and treats redundant sideband metadata as a consistency check.
- The module keeps one stable output port set instead of hiding metadata behind separate wrappers at this stage.
- `protocol_error` is sticky to make malformed-traffic bugs visible during integration.
- `DROP_BAD_PACKET` suppresses payload but still preserves parser state and packet close behavior.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- zero-payload packet handling in header mode
- trailer parsing
- richer packet-length enforcement against observed payload beats
- randomized long-stream regressions
- deeper formal proofs for packet state progression

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve malformed-packet handling
   - add explicit counters and cause codes for header, metadata, and boundary errors
   - add configurable resynchronization policy after severe framing corruption

2. Improve throughput flexibility
   - add lookahead buffering for tighter header-to-payload handoff timing
   - add wrappers for lighter payload-only or metadata-heavy integration profiles

3. Expand verification breadth
   - add randomized malformed-stream regressions
   - add stronger formal checks for packet-state reset and payload-boundary normalization
