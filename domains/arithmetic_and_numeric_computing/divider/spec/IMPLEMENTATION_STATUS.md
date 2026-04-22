# Divider Implementation Status

## Current Status

`divider` is implemented as a reusable exact integer divider with explicit signedness, divide-by-zero handling, and signed-overflow handling.

The current implementation supports:

- exact unsigned quotient and remainder
- exact signed quotient and remainder under truncation-toward-zero semantics
- divide-by-zero status with configurable quotient fill
- signed most-negative divided by `-1` overflow handling
- optional remainder suppression

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for unsigned divide, signed divide, divide-by-zero policy, signed overflow saturation, and remainder suppression
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small signed configuration

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_divider_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- the baseline is combinational and policy-focused rather than area-optimized
- signed overflow is surfaced explicitly instead of being left implicit in quotient wrap behavior
- divide-by-zero returns the dividend as remainder before optional output suppression
- remainder suppression quiets only the port, not the quotient or status outputs

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- iterative or pipelined divider architectures
- fixed-point quotient scaling modes
- selectable alternate divide-by-zero remainder policies
- alternate signed remainder convention families

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
