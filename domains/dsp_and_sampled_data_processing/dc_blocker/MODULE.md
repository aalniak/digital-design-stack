# DC Blocker

## Overview

The DC blocker removes constant or slowly varying bias from a sampled stream so later DSP stages can use their dynamic range more effectively. It is a small but important conditioning primitive for receivers, sensor chains, and audio paths.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Offset introduced by sensors, ADCs, mixers, or analog front ends can waste dynamic range and distort algorithms that assume zero-centered signals. This module suppresses the near-zero-frequency component so downstream detection, filtering, and AGC work on the informative part of the signal.

## Typical Use Cases

- Removing receiver or ADC offset ahead of AGC, demodulation, or correlation.
- Cleaning microphone or sensor data before spectral analysis.
- Stabilizing baseline levels in measurement pipelines where long-term drift is common.

## Interfaces and Signal-Level Behavior

- Input side accepts scalar real or complex samples with normal streaming timing.
- Output side emits bias-reduced samples and may expose the estimated offset for monitoring.
- Control side configures the time constant or equivalent filter coefficient and reset behavior.

## Parameters and Configuration Knobs

- Sample width, complex versus real mode, time constant or pole coefficient, and internal precision.
- Rounding or saturation mode and whether offset estimates are externally visible.
- Support for runtime coefficient updates or fixed compile-time behavior.

## Internal Architecture and Dataflow

Many DC blockers are implemented as simple first-order high-pass filters or subtractive running-average estimators. The hardware keeps a slow-moving estimate of the offset and subtracts it from the incoming sample. Although conceptually simple, the design still needs careful scaling because too short a time constant distorts low-frequency content while too long a constant leaves residual offset in place.

## Clocking, Reset, and Timing Assumptions

The chosen coefficient encodes a tradeoff between baseline removal and low-frequency signal preservation, so the documentation should tie it to sample rate and expected signal bandwidth. Reset policy matters because clearing the estimator causes a startup transient until the baseline is learned again.

## Latency, Throughput, and Resource Considerations

The block is lightweight and usually sustains one sample per cycle with very small resource cost. Latency is short, but convergence time in signal terms depends on the configured time constant.

## Verification Strategy

- Apply known offsets and slow drifts to confirm the residual DC level converges as expected.
- Check low-frequency tone preservation so the blocker does not remove wanted signal content excessively.
- Verify reset and coefficient-change transients against a reference model.

## Integration Notes and Dependencies

DC blockers typically sit immediately after acquisition or mixing. Integrators should choose coefficients with awareness of the real sample rate and the lowest frequency content that must be preserved, not just generic intuition.

## Edge Cases, Failure Modes, and Design Risks

- Overaggressive blocking can erase desired low-frequency content along with the offset.
- If the sample rate changes but the coefficient does not, the effective corner frequency shifts unexpectedly.
- Startup transients may be misinterpreted as real signal energy unless downstream logic accounts for them.

## Related Modules In This Domain

- agc_block
- biquad_iir
- digital_mixer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DC Blocker module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
