# Event Counter Implementation Status

## Current Status

`event_counter` is implemented and verified as the reusable local statistics primitive for synchronous event observability.

The current implementation supports:

- configurable count width through `COUNT_WIDTH`
- wrap or saturate behavior through `SATURATE`
- threshold compare through `THRESHOLD_EN` and `THRESHOLD_VALUE`
- optional snapshot behavior through `SNAPSHOT_EN`
- explicit clear policy through `CLEAR_PRIORITY`
- sticky overflow reporting

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for wrap-mode behavior
- self-checking simulation for saturate-mode behavior
- threshold and snapshot checks
- Yosys synthesis sanity
- SymbiYosys formal proof of selected public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_event_counter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The public interface stays stable even when threshold or snapshot features are disabled.
- Snapshot capture records the post-update visible count for that cycle.
- Threshold reporting is level-based rather than edge-based.
- Clear can either win outright or establish the base for a same-cycle count, depending on `CLEAR_PRIORITY`.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- threshold-crossing pulse generation
- CSR-facing wrappers with read-clear conventions
- freeze-style control separate from snapshot capture
- automated parameter sweeps across broader width and reset-value combinations
- deeper formal proofs for snapshot semantics and wrap ordering

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add width and reset-value sweeps
   - strengthen formal properties around wrap and snapshot behavior

2. Grow the wrapper family
   - add CSR and interrupt-friendly wrappers if needed
   - add threshold-crossing pulse or sticky-threshold variants

3. Improve software-facing semantics
   - define and implement standard snapshot-clear and read-clear wrapper patterns
