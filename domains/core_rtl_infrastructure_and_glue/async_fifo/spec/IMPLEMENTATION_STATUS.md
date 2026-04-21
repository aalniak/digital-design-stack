# Async FIFO Implementation Status

## Current Status

`async_fifo` is the first implemented and verified module family in the library. The family currently includes:

- `async_fifo_core.sv`
- `async_fifo_native.sv`
- `async_fifo_stream.sv`
- `async_fifo_packet.sv`

The current implementation supports:

- power-of-two depth asynchronous FIFO storage
- Gray-coded pointer CDC
- native local enqueue and dequeue wrapper
- `valid/ready` stream wrapper
- packet wrapper with packed `last`, `keep`, and `user` sidebands
- local-domain occupancy outputs
- almost-full and almost-empty watermarks
- overflow and underflow diagnostics in the native wrapper

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- native self-checking simulation
- stream self-checking simulation
- packet self-checking simulation
- Yosys synthesis sanity
- SymbiYosys formal proof of selected public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_async_fifo_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- `wr_full` and `rd_empty` are implemented as registered local-domain status flags.
- The family currently assumes a standard Gray-pointer architecture and therefore requires `DEPTH` to be a power of two.
- Packet sidebands are carried by packing them into the stored payload word rather than maintaining a separate sideband path.

## What Is Not Implemented Yet

The current RTL does not yet implement every capability described in the broader family contract.

Not yet implemented or not yet generalized:

- configurable first-word fall-through behavior
- configurable output-register policy
- richer wrapper family selection or package-level type support
- deeper illegal-configuration regression coverage
- broader formal proof of internal pointer and ordering invariants
- parameter sweep automation beyond the currently exercised test configurations

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: between `bronze` and `silver`

Reasoning:

- the family is implemented and passes directed and randomized-style self-checking simulations
- synthesis sanity passes
- a lightweight formal proof passes
- broader configuration sweeps and stronger internal proofs are still outstanding

## Highest-Value Improvements

1. Strengthen formal verification
   - add deeper core properties around ordering, occupancy bounds, and pointer evolution
   - add wrapper-local properties for stream and packet semantics

2. Expand configuration coverage
   - automate representative sweeps over `DATA_WIDTH`, `DEPTH`, and `SYNC_STAGES`
   - add explicit negative tests for illegal parameter combinations

3. Add timing and latency variants
   - introduce explicit `FWFT` behavior if needed
   - introduce configurable output-register behavior without muddying the public contract

4. Improve synthesis mapping flexibility
   - add implementation hints or wrapper patterns for FPGA RAM inference choices
   - validate behavior across shallow register-based and deeper memory-based realizations

5. Improve package and wrapper hygiene
   - consider a small package or shared definitions file for family-wide parameters and packed sideband conventions

## Recommendation For Next Iteration

Keep `async_fifo` as the reference family for:

- wrapper-based public interface selection
- verification-runner structure
- implementation-status tracking

Then extend the same pattern to the other CDC primitives, especially `pulse_synchronizer` and `bus_synchronizer`, so the core library gains a coherent set of low-rate, event, and stream crossing blocks.
