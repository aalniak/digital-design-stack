# Bus Synchronizer Implementation Status

## Current Status

`bus_synchronizer` is implemented and verified as a single-entry multi-bit CDC handshake for low-rate payload transfers.

The current implementation supports:

- one payload in flight at a time
- source-side `valid/ready` acceptance
- destination-side registered `data`, `valid`, and `pulse`
- configurable `DATA_WIDTH`
- configurable synchronizer depth through `SYNC_STAGES`
- reset value control through `RESET_VALUE`

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking randomized simulation with source and destination backpressure behavior
- Yosys synthesis sanity
- SymbiYosys formal proof of selected public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_bus_synchronizer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The block is intentionally single-entry rather than queue-based.
- The destination interface is registered, so `dst_valid` presentation and `dst_ready` consumption follow synchronous handshake timing rather than combinational same-cycle acceptance.
- Payload stability relies on holding the source buffer constant until the acknowledge path returns.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- multi-entry storage or burst crossing
- packet sideband handling beyond the base payload bus
- alternative wrappers for native request/ack or stream-only presentation
- deeper formal proofs around ordering and progress under constrained legal environments
- automated parameter sweeps across wider `DATA_WIDTH` and `SYNC_STAGES` combinations

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Strengthen the formal contract
   - add more constrained end-to-end properties around acceptance and delivery ordering
   - separate public-interface properties from deeper internal-structure properties

2. Expand the family shape
   - add wrappers for stream-only, ack-style, or sideband-carrying variants
   - consider a queue-backed sibling for higher-rate traffic

3. Increase configuration coverage
   - sweep payload widths, reset values, and synchronizer depths
   - add more reset-phase and backpressure stress combinations
