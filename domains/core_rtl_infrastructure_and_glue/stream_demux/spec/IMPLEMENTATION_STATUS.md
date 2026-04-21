# Stream Demux Implementation Status

## Current Status

`stream_demux` is implemented and verified as the baseline same-clock one-to-many steering primitive for the core library.

The current implementation supports:

- configurable payload width through `DATA_WIDTH`
- configurable metadata width through `SIDEBAND_WIDTH`
- configurable fan-out through `NUM_OUTPUTS`
- optional held-route behavior for multi-beat packets
- selectable invalid-route stall or drop policy
- status visibility through `invalid_route`, `held_route_active`, and `held_route_select`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for single-beat routing, backpressure, held-route packet steering, and invalid-route drop behavior
- Yosys synthesis sanity
- SymbiYosys lightweight formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_stream_demux_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The baseline module has no internal buffering.
- Held-route behavior is keyed from accepted beats and `s_last`.
- Invalid-route handling is explicit and parameterized.
- The module favors wrapper composition with FIFOs or skid buffers rather than trying to do everything internally.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- integrated buffering for timing isolation
- `first`-aware packet-state validation
- richer invalid-route diagnostics and counters
- broader formal proofs for route-hold evolution across arbitrary traffic

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Strengthen flow control variants
   - add optional skid buffering on the ingress or selected output path
   - add route-lock variants for multi-cycle non-packet transactions

2. Expand verification breadth
   - add randomized packet-route sequences with varying stall patterns
   - add stronger formal checks for hold-state transitions and invalid-route policy

3. Improve integration support
   - define standard route-sideband conventions for packetizer and depacketizer flows
