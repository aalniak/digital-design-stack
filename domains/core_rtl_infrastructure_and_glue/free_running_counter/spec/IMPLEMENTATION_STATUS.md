# Free-Running Counter Implementation Status

## Current Status

`free_running_counter` is implemented and verified as the reusable local cycle timebase primitive.

The current implementation supports:

- configurable count width through `COUNT_WIDTH`
- configurable reset value through `RESET_VALUE`
- optional enable gating through `ENABLE_EN`
- optional rollover pulse generation through `ROLLOVER_PULSE_EN`
- optional capture semantics through `CAPTURE_EN`
- synchronous load priority over counting

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for gated-count behavior
- self-checking simulation for always-enabled behavior
- load, capture, and rollover checks
- Yosys synthesis sanity
- SymbiYosys formal proof of selected public-contract invariants

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_free_running_counter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- Load has priority over counting.
- Capture records the post-update visible count for that cycle.
- Disabled features keep stable outputs rather than changing the public port set.
- Rollover pulse only reflects a counted wrap, not an arbitrary load to zero.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- compare-match outputs
- prescaled or divided timebase wrappers
- multi-bank capture or shadow registers
- automated parameter sweeps across broader widths and reset values
- deeper formal checks for enable hold and load priority timing

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Expand verification breadth
   - add width and reset-value sweeps
   - strengthen formal properties around load and gated hold behavior

2. Grow the timebase family
   - add compare-match and timer-wrapper variants
   - add prescaler or programmable tick wrappers where needed

3. Improve software-facing integration
   - define wrapper patterns for timestamp capture and CSR reads
