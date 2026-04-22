# Abs Min Max Implementation Status

## Current Status

`abs_min_max` is implemented as a reusable compare-select and absolute-value helper with explicit signedness and most-negative-input policy.

The current implementation supports:

- signed or unsigned min and max selection
- equality and less-than flag outputs
- absolute value for `operand_a`
- configurable saturation or wrap-preserve behavior on the signed most-negative corner case

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for signed compare-select, unsigned compare-select, equality behavior, saturating abs, and non-saturating most-negative abs behavior
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small signed saturating configuration

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_abs_min_max_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- only `operand_a` feeds the absolute-value path in the baseline
- `abs_saturated` reports clipping only on the signed most-negative corner case
- unsigned mode bypasses the abs transform entirely
- the current baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- dual abs outputs or parallel magnitude compare modes
- pipelined latency options
- configurable tie-breaking metadata
- overflow signaling for the non-saturating most-negative mode

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
