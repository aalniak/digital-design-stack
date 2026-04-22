# Timestamp Counter Implementation Status

## Current Status

`timestamp_counter` is implemented as a reusable free-running timestamp primitive with synchronous control hooks for clear, load, capture, and compare.

The current implementation supports:

- unit-step free-running count
- synchronous clear and load with deterministic priority
- pre-update timestamp capture
- post-update compare-hit pulse generation
- overflow pulse on wraparound

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for increment, capture, load, compare hit, and overflow behavior
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_timestamp_counter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- capture samples the pre-update count value
- compare operates on the next visible timestamp value
- clear takes priority over load and increment

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- programmable increment steps
- multiple capture channels
- external time-discipline correction inputs
- randomized long-run wrap and compare regressions

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
