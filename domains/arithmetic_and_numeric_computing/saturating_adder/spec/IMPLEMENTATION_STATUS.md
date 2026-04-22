# Saturating Adder Implementation Status

## Current Status

`saturating_adder` is implemented as a combinational bounded-add primitive with explicit clipping flags and optional custom numeric limits.

The current implementation supports:

- signed or unsigned bounded addition
- optional carry-in increment on addition
- default native numeric bounds or caller-provided custom bounds
- explicit `saturated`, `at_min`, and `at_max` outputs

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for signed saturation, unsigned saturation, carry-in behavior, and custom-limit clipping
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small signed custom-limit instance

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_saturating_adder_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- clipping is performed against the active configured range, not only against the native format range
- custom limits are treated as a caller responsibility and must be ordered correctly
- `FLAG_EN = 0` suppresses the clipping flags but not the clipped result itself
- the baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- invalid custom-limit detection
- subtract or MAC-style accumulation variants
- pipelined latency options
- separate raw widened-sum observability

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
