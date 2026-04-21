# Frequency Meter

## Overview

frequency_meter estimates or counts the frequency of a target clock relative to a trusted reference interval. It is an observability block for bring-up, monitoring, and calibration.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

A simple lock signal does not reveal whether a clock is actually running at the intended rate. frequency_meter gives software and hardware a quantitative timing measurement.

## Typical Use Cases

- Measure PLL or oscillator output frequency.
- Check programmable clock settings during bring-up.
- Provide telemetry for manufacturing test or field diagnostics.

## Interfaces and Signal-Level Behavior

- Inputs generally include reference clock, measured clock, reset, and optional measurement-start control.
- Outputs include measured count or code, valid, and optional out-of-range flags.
- Configuration may set the measurement window and allowed thresholds.

## Parameters and Configuration Knobs

- COUNT_WIDTH sizes counters.
- WINDOW_LENGTH sets measurement interval.
- CONTINUOUS_MODE enables repeated sampling.
- RANGE_CHECK_EN adds threshold flags.
- AVERAGING_EN smooths noisy results.

## Internal Architecture and Dataflow

Most implementations count measured edges within a reference window or count reference cycles between measured edges. The chosen method should match the expected frequency range and desired resolution.

## Clocking, Reset, and Timing Assumptions

A trusted reference clock must exist. The measured clock may be asynchronous to that reference, so edge capture and off-by-one rules need explicit treatment. Reset should define when the first reading becomes valid.

## Latency, Throughput, and Resource Considerations

Longer windows improve resolution but increase latency. Hardware cost is modest and mostly comes from counters and optional averaging state.

## Verification Strategy

- Measure known ratios and compare against expected counts.
- Sweep the measured clock around threshold boundaries.
- Check startup latency to first valid result.
- Inject jitter or missing edges to test averaging and flags.

## Integration Notes and Dependencies

frequency_meter complements lock and fail detectors by providing a number rather than only a boolean health status. It often feeds software-visible registers or supervisory logic.

## Edge Cases, Failure Modes, and Design Risks

- Software may mistake a windowed average for an instantaneous measurement.
- Asynchronous edge capture can be off by one without a documented convention.
- An unhealthy reference clock invalidates the measurement silently.

## Related Modules In This Domain

- clock_fail_detector
- pll_lock_monitor
- pps_capture
- timestamp_counter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frequency Meter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
