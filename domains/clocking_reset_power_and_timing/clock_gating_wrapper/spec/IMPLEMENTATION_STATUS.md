# Clock Gating Wrapper Implementation Status

## Current Status

`clock_gating_wrapper` is implemented as a first reusable low-phase-latched gating policy block with an explicit FPGA-safe mode.

The current implementation supports:

- source-clock enable synchronization
- polarity-configurable enable requests
- test and functional bypass overrides
- low-phase gate-state acceptance
- free-running clock plus CE semantics for FPGA-safe integration

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for reset behavior, safe gate open and close, test bypass override, functional bypass override, FPGA-safe clock passthrough semantics, and active-low enable polarity
- Yosys synthesis sanity
- SymbiYosys formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_gating_wrapper_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The accepted gate state is only allowed to change on the low phase of `clk_in`.
- `domain_ce` is always exported, even when a physically gated clock is produced, so policy intent remains observable.
- `FPGA_SAFE_MODE` intentionally keeps `gated_clk` free-running and treats `domain_ce` as the integration contract.
- Override requests are visible immediately through `override_active`, but their effect on the accepted gate state is still low-phase aligned.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- foundry-cell mapping or vendor primitive binding
- dedicated synchronizers for bypass controls
- glitchless multi-clock handoff behavior
- deeper formal proofs for pulse acceptance and closure latency bounds

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve technology realism
   - add wrapper profiles that map cleanly onto ASIC ICG cells
   - add CE-only wrapper variants for FPGA-facing integration

2. Improve control robustness
   - add explicit acknowledge outputs for accepted gate transitions
   - add optional synchronization or handshake-based control for bypass paths

3. Expand verification breadth
   - add randomized enable and override phase-sweep regressions
   - add deeper formal checks for no-spurious-pulse behavior across state changes
