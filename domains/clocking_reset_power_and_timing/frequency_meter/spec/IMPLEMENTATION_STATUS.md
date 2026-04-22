# Frequency Meter Implementation Status

## Current Status

`frequency_meter` is implemented as a first reusable quantitative clock-observability block based on synchronized measured-edge counter snapshots.

The current implementation supports:

- one-shot or continuous measurement windows
- quantitative edge-count output over a fixed reference interval
- optional threshold range checking
- optional exponential moving-average smoothing
- reset-quiet result and status behavior

## Verified Today

The current verification flow passes end to end under the checked OSS CAD Suite environment.

Passing checks:

- self-checking simulation for one-shot measurement, continuous measurement, threshold flags, averaging behavior, disabled-idle behavior, and stopped-clock measurement
- Yosys synthesis sanity
- SymbiYosys formal reset-state check

Verification entry point:

- `powershell -ExecutionPolicy Bypass -File .\scripts\run_frequency_meter_verification.ps1`

Verification outputs land in:

- `tb/out/`

## Important Current Design Choices

- The baseline measures synchronized edge deltas rather than attempting direct Hertz scaling.
- The measured-domain counter is free-running so the measured clock domain has no asynchronous control input.
- Continuous mode restarts with a one-cycle idle boundary between windows.
- Averaging is an exponential moving average using `AVERAGE_SHIFT`, not a multi-sample boxcar accumulator.
- Abrupt measured-clock rate changes can produce one transitional continuous sample before the meter settles to the new steady-state count.

## What Is Not Implemented Yet

Not yet implemented or not yet generalized:

- runtime-programmable window length or averaging settings
- explicit scaled-frequency output in fixed-point units
- dedicated stale-clock status beyond a zero-count sample
- deeper formal checks for continuous-mode restart sequencing

## Current Maturity

- implementation maturity: early reusable baseline
- verification maturity: bronze to silver

## Highest-Value Improvements

1. Improve observability
   - add calibrated fixed-point frequency output and reference-rate scaling hooks
   - add explicit zero-edge and stale-sample status bits

2. Improve configurability
   - add runtime-programmable window length and threshold registers
   - add selectable averaging modes and averaging reset policy

3. Expand verification breadth
   - add randomized phase and jitter regressions
   - add deeper formal checks for delta accounting and mode transitions
