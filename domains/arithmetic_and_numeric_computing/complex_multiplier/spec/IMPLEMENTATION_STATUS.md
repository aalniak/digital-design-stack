# Complex Multiplier Implementation Status

## Current Status

`complex_multiplier` is implemented as a reusable widened complex-product primitive with optional operand-B conjugation.

The current implementation supports:

- signed or unsigned interpretation of the input components
- fixed-width conjugation of operand B's imaginary component
- widened real and imaginary outputs sized for the recombination stage

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for signed complex multiplication, signed conjugated multiplication, and unsigned multiplication
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small signed instance with arbitrary conjugation control

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_complex_multiplier_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- the implementation uses the straightforward four-real-multiply form
- conjugation happens before multiplication in fixed input width
- outputs are widened to preserve the recombination bit growth
- the baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- three-multiplier optimized forms
- pipelined DSP-friendly variants
- output narrowing and rounding policies
- explicit overflow or saturation signaling

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
