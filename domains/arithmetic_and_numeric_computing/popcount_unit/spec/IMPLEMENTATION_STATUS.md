# Popcount Unit Implementation Status

## Current Status

`popcount_unit` is implemented as a reusable exact bit-count primitive with optional zero and full flags.

The current implementation supports:

- exact total population count
- zero-detect and full-detect flags
- flag suppression without affecting count behavior

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for zero, full, sparse, alternating, and flag-suppressed cases
- Yosys synthesis sanity
- SymbiYosys exact combinational proof for a small instance

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_popcount_unit_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- output width is sufficient for the exact count, so the baseline never truncates
- flags describe the entire vector rather than a partial segment
- flag suppression keeps the count live while quieting convenience outputs
- the baseline is purely combinational

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- segmented or hierarchical count outputs
- saturating or narrowed count modes
- pipelined very-wide-mask variants
- per-segment consistency flags

## Current Maturity

- implementation maturity: reusable baseline
- verification maturity: silver
