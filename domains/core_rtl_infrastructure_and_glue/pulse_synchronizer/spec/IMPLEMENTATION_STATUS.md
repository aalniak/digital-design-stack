# Pulse Synchronizer Implementation Status

## Current Status

`pulse_synchronizer` is implemented and verified as a single-event CDC primitive for sparse control transfers.

The current implementation supports:

- toggle-based event transfer
- one event in flight at a time
- source-side `src_busy` backpressure
- destination-side single-cycle `dst_pulse`
- configurable synchronizer depth through `SYNC_STAGES`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation across unrelated source and destination clocks
- Yosys synthesis sanity
- SymbiYosys formal proof of selected public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_pulse_synchronizer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The implementation uses a request-toggle and acknowledge-toggle handshake rather than raw pulse stretching.
- The current block intentionally exposes `src_busy` so the source domain can obey the one-event-in-flight contract.
- Destination behavior is a one-cycle regenerated pulse rather than a level output.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- queueing or counting of overlapping pulses
- selectable destination pulse stretching modes
- optional wrapper variants that hide or reshape `src_busy`
- stronger formal coverage of liveness under constrained legal stimulus
- automated parameter sweeps beyond the current checked configuration

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Strengthen proof depth
   - add more explicit legal-environment assumptions
   - prove one accepted source event maps to one destination pulse under those assumptions

2. Expand wrapper options
   - add variants for interrupt-style outputs or explicit acknowledge ports
   - consider a family split if pulse stretching becomes a real use case

3. Broaden regression coverage
   - sweep `SYNC_STAGES`
   - add more reset-during-traffic stress cases
