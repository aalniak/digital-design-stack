# Packetizer Implementation Status

## Current Status

`packetizer` is implemented as a baseline packet-normalization block with two framing modes.

The current implementation supports:

- sideband-only framing
- one-beat synthetic header insertion
- sticky protocol-error reporting for malformed upstream sequencing
- packet-level metadata capture and reuse across payload beats
- optional restart tolerance through `AUTO_CLOSE_EN`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for sideband-only framing, sticky sequencing error behavior, header insertion, held-first-payload behavior, and metadata reuse
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_packetizer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- Header mode inserts a synthetic header beat rather than mutating the first payload beat.
- The module keeps a stable port set regardless of framing mode.
- `protocol_error` is sticky so integration bugs remain visible instead of becoming one-cycle ghosts.
- Trailer support is intentionally not faked. The current baseline rejects `TRAILER_EN != 0`.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- actual trailer generation
- packet abort and drop behavior
- deeper input buffering for bubble-free header insertion
- packet length computation from observed payload beats
- richer formal coverage around sequencing violations

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve packet framing flexibility
   - add trailer mode and checksum placeholder support
   - add optional in-band header formatting variants

2. Improve throughput behavior
   - add deeper buffering to allow header insertion without front-end stalls
   - add wrapper profiles for common packet record layouts

3. Expand verification breadth
   - add randomized malformed-sequence scenarios
   - add stronger formal checks for packet-boundary normalization
