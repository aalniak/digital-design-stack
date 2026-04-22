# Adder Subtractor Implementation Status

## Current Status

`adder_subtractor` is implemented as a combinational arithmetic primitive with explicit flag semantics for addition and subtraction.

The current implementation supports:

- selectable add or subtract operation
- optional carry-in on addition
- carry-out or no-borrow reporting
- signed overflow reporting
- zero and negative flags

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for unsigned add, carry-in, subtract, borrow indication, and signed overflow behavior
- Yosys synthesis sanity
- SymbiYosys lightweight exact-combinational proof

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_adder_subtractor_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- subtraction ignores `carry_in` in the current baseline
- signedness affects flags only, not the underlying bit arithmetic
- the baseline is combinational rather than pipelined

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- borrow-in chaining for subtraction
- pipelined latency options
- saturation support in this module

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
