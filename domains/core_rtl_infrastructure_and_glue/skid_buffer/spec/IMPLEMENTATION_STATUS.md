# Skid Buffer Implementation Status

## Current Status

`skid_buffer` is implemented and verified as the reusable valid-ready primitive for capturing the first extra beat that can appear when backpressure arrives too late.

The current implementation supports:

- configurable payload width through `DATA_WIDTH`
- configurable sideband width through `SIDEBAND_WIDTH`
- configurable elasticity through chained skid depth with `DEPTH`
- direct bypass operation through `DEPTH = 0`
- sideband alignment through all configured skid stages

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- directed first-stall capture simulation
- self-checking randomized simulation for `DEPTH = 0`, `DEPTH = 1`, and `DEPTH = 2`
- payload and sideband ordering checks
- held-output stability checks during stalls
- Yosys synthesis sanity
- SymbiYosys formal proof of reset-safety public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_skid_buffer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The current family uses chained single-entry skid stages instead of a monolithic micro-FIFO.
- `DEPTH = 0` is the current bypass mechanism.
- The empty path remains combinational for `DEPTH > 0` in this first implementation.
- Stored beats are allowed to drain and refill in the same cycle to preserve one-beat-per-cycle throughput.
- The reset-oriented formal proof assumes upstream logic drives `s_valid = 0` while reset is active.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- explicit `REGISTER_READY` mode selection
- explicit low-latency versus fully-registered mode split
- occupancy counters or debug visibility outputs
- automated parameter sweeps across broader depth and width combinations
- deeper formal proofs for ordering and stall behavior across multi-stage chains

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add width and depth sweep automation
   - add stronger formal properties around hold behavior and chain ordering

2. Grow the family shape
   - add explicit registered-ready and registered-output variants
   - align future variants with the planned register-slice sibling modes

3. Improve integration visibility
   - add optional occupancy outputs or debug state exposure where helpful
