# Register Slice Implementation Status

## Current Status

`register_slice` is implemented and verified as the reusable valid-ready timing-relief primitive for a single clock domain.

The current implementation supports:

- configurable payload width through `DATA_WIDTH`
- configurable sideband width through `SIDEBAND_WIDTH`
- configurable elastic depth through `STAGES`
- direct bypass operation through `STAGES = 0`
- sideband alignment through all configured registered stages

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for bypass behavior
- self-checking simulation for multi-stage behavior
- output stall-stability checks
- payload and sideband ordering checks
- Yosys synthesis sanity
- SymbiYosys formal proof of reset-safety public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_register_slice_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The current family uses an elastic-stage architecture rather than fixed named mode variants.
- `STAGES = 0` is the current bypass mechanism.
- Reverse-path ready remains combinational across the stage chain in this first implementation.
- Sidebands are packed and advanced with payload to preserve beat coherence.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- explicit forward-only versus fully-registered mode split
- occupancy status outputs
- low-power invalid-payload clearing behavior
- automated parameter sweeps across broader stage and width combinations
- stronger formal checks for stall behavior under this proof harness style
- deeper formal end-to-end ordering proofs for multi-stage pipelines

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add width and stage sweeps
   - add stronger formal properties around ordering, stall behavior, and throughput

2. Grow the family shape
   - add explicit mode variants for different handshake timing strategies
   - align future variants with the planned skid-buffer sibling

3. Improve integration visibility
   - add optional occupancy or empty/full style status outputs where helpful
