# Reset Synchronizer Implementation Status

## Current Status

`reset_synchronizer` is implemented and verified as the reusable local-reset release primitive for a single clock domain.

The current implementation supports:

- configurable release depth through `STAGES`
- active-low and active-high reset polarity through `ACTIVE_LOW`
- asynchronous or synchronous assertion policy through `ASYNC_ASSERT`
- explicit `release_done` status output

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for active-low asynchronous assertion
- self-checking simulation for active-high synchronous assertion
- release-latency checks for both exercised configurations
- Yosys synthesis sanity
- SymbiYosys formal proof of selected public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_reset_synchronizer_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The current RTL normalizes the incoming reset to an internal asserted-high representation.
- Release behavior is driven by an asserted-state shift register.
- `release_done` is the contract-level indication that the local reset has fully deasserted.
- The first implementation keeps the family intentionally compact rather than adding bypass and test hooks immediately.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- vendor-specific synchronizer preservation attributes beyond the base `async_reg` hint
- test-mode bypass or scan override behavior
- explicit release pulse output separate from `release_done`
- automated parameter sweeps over a broader set of release depths and polarity combinations
- a second formal harness for the alternate polarity and assertion-mode combinations

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - prove additional polarity and assertion-mode combinations formally
   - automate parameter sweeps across representative `STAGES` values

2. Improve implementation portability
   - add vendor-wrapper guidance or optional attributes for FPGA and ASIC flows
   - document reset-tree integration recommendations more concretely

3. Grow the family carefully
   - add optional bypass or release-pulse wrappers only if those use cases become common
   - keep the core primitive minimal and easy to reason about
