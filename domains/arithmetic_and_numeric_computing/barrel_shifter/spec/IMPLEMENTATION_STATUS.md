# Barrel Shifter Implementation Status

## Current Status

`barrel_shifter` is implemented as a reusable variable-shift primitive with explicit mode encoding, oversize-count semantics, and optional sticky reporting.

The current implementation supports:

- logical left shift
- logical right shift
- arithmetic right shift
- rotate-left
- sticky-bit reporting for discarded bits in non-rotate modes

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for left shift, logical right shift, arithmetic right shift, rotate-left, oversize shift behavior, and sticky suppression
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small sticky-enabled configuration

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_barrel_shifter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- rotate mode is rotate-left only in the baseline
- sticky is zero in rotate mode even when bits wrap around
- oversize arithmetic right shift sign-fills the full word
- the baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- rotate-right mode
- shifted-out bus output
- pipelined latency options
- configurable mode subsets or opcode remapping

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
