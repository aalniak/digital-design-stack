# PPS Capture Implementation Status

## Current Status

`pps_capture` is implemented as a configurable qualified-edge timestamp capture block with optional interval measurement.

The current implementation supports:

- rising- or falling-edge capture selection
- direct or synchronized PPS sampling
- optional transition filtering
- interval measurement after the first valid capture
- glitch rejection pulse and sticky status

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for first-capture behavior, interval measurement, glitch rejection, clear handling, and filtered edge qualification
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_pps_capture_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- the captured timestamp is the sampled local counter value, not a compensated estimate
- deasserting `enable` clears capture history and re-arms first-capture behavior
- filtering operates on the PPS level before edge detection, not on already-detected pulses

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- interval-based missing-pulse or double-pulse fault classification
- both-edge capture profile
- explicit capture-uncertainty reporting for asynchronous inputs
- randomized jitter regressions beyond the directed first-pass testbench

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
