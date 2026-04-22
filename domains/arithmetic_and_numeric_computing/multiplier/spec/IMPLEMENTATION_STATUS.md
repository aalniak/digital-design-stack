# Multiplier Implementation Status

## Current Status

`multiplier` is implemented as a reusable exact-product primitive with configurable signedness and exported product slice selection.

The current implementation supports:

- unsigned or signed multiplication
- exact internal full-product computation
- low-slice or high-slice result export
- discarded-bit observability through `discarded_nonzero`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for unsigned full-width multiplication, low-slice export, high-slice export, and signed multiplication
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small signed sliced instance

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_multiplier_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- full product generation is authoritative and slicing is derived from it
- `discarded_nonzero` reports whether any omitted bits are high
- high-slice mode is direct bit extraction rather than rounded or scaled narrowing
- the baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- pipelined DSP-friendly variants
- rounded narrowing policies
- mixed signedness per operand
- explicit full-product output alongside the selected slice

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
