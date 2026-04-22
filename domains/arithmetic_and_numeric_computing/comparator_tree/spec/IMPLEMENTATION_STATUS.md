# Comparator Tree Implementation Status

## Current Status

`comparator_tree` is implemented as a reusable masked winner-select primitive with deterministic tie-breaking and optional index reporting.

The current implementation supports:

- max or min reduction
- signed or unsigned numeric interpretation
- valid-mask filtering of candidates
- deterministic lowest-index tie-breaking
- optional suppression of the reported winner index

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for signed max selection, unsigned min selection, tie-breaking, mask handling, and all-invalid behavior
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small signed max configuration

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_comparator_tree_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- tie-breaking intentionally preserves the first matching input index
- the baseline uses a packed vector interface rather than a SystemVerilog unpacked array port
- `RETURN_INDEX_EN = 0` zeroes the index output but does not remove the internal selection bookkeeping
- the current implementation is functionally a reduction contract, not a timing-optimized balanced tree

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- pipelined stage insertion for large fan-in timing closure
- forwarded metadata payloads other than index
- explicit equal or compare flag outputs
- hierarchical tree balancing for better placement and routing behavior

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
