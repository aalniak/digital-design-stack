# Wakeup Controller Implementation Status

## Current Status

`wakeup_controller` is implemented as a small wake-source qualifier and sticky pending-bit accumulator intended for always-on supervisory logic.

The current implementation supports:

- per-source enable masking
- per-source edge-versus-level trigger selection
- sticky pending wake bits with masked clear
- aggregate wake request generation while sleep is armed
- one-cycle pulse on newly detected enabled wake events

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for level wake, edge wake, masked-source suppression, sticky pending retention, and masked clear
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_wakeup_controller_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- wake qualification happens after masking, not before
- edge-triggered sources only detect rising transitions
- `wake_request` is intentionally gated by `sleep_armed` even if pending bits exist

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- source synchronization for asynchronous wake inputs
- polarity inversion or falling-edge modes
- debounce, glitch filtering, or priority encoding
- randomized long-run toggle regressions

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
