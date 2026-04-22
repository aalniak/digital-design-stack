# Clock Fail Detector Implementation Status

## Current Status

`clock_fail_detector` is implemented as the first reference-domain clock-health monitor in the clocking library.

The current implementation supports:

- timeout-based activity loss detection
- window-based min/max edge counting
- fault qualification through `FILTER_DEPTH`
- sticky or non-sticky fault behavior
- optional automatic recovery for non-sticky faults

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for healthy operation, timeout detection, sticky-fault hold behavior, explicit fault clear, slow-clock window violation, fast-clock window violation, and non-sticky auto recovery
- Yosys synthesis sanity
- SymbiYosys formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_clock_fail_detector_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The baseline uses a synchronized toggle to observe monitored activity inside the reference domain.
- Fault qualification is shared between timeout and window violations through one filter counter.
- Sticky fault and automatic recovery behavior are explicitly separated rather than implied.
- The module is positioned as a supervisor and policy input, not as a precision frequency meter.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- separate sticky cause bits for timeout and window failures
- hysteresis-based recovery thresholds
- high-rate monitored-clock supervision beyond the toggle-sampler assumption
- randomized jitter regressions and deeper formal proofs

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve observability
   - add separate sticky timeout and window-fault causes
   - add filtered-health counters for software diagnostics

2. Improve robustness
   - add hysteresis between fail and recover behavior
   - add higher-fidelity sampling for faster monitored clocks

3. Expand verification breadth
   - add randomized missing-edge and jitter scenarios
   - add deeper formal checks for filter-depth behavior and recovery semantics
