# Reset Sequencer Implementation Status

## Current Status

`reset_sequencer` is implemented as a supervisory-clock FSM that waits for prerequisites and then releases reset outputs in a fixed order.

The current implementation supports:

- fully asserted startup state
- explicit start-sequence trigger
- optional prerequisite gating
- one-by-one reset release with fixed inter-step delay
- timeout fault reporting while waiting for prerequisites
- sticky timeout fault retention until `clear_fault`
- restart to idle on global reset request

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for timeout behavior, ordered reset release, step pulses, ready assertion, and restart to idle on global reset request
- Yosys synthesis sanity
- SymbiYosys lightweight public-contract proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_reset_sequencer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- release ordering is fixed from index `0` upward
- the first baseline uses one shared release delay for every reset step
- timeout monitoring applies only before release begins
- a later successful retry does not clear `timeout_fault` unless software asserts `clear_fault`

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- per-reset delay vectors
- acknowledgment-driven steps
- partial recovery or subset re-entry
- randomized restart and fault injection regressions

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver
