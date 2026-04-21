# IMU Preintegration

## Overview

IMU Preintegration accumulates inertial measurements over a defined interval into delta position, delta velocity, delta angle, and related uncertainty terms. It produces compact motion summaries for downstream fusion engines.

## Domain Context

IMU preintegration packages high-rate inertial data into a form that can be fused efficiently with slower GNSS and other navigation measurements. In sensor-fusion systems it reduces the cost of handling every raw accelerometer and gyroscope sample individually while preserving the motion information between measurement epochs.

## Problem Solved

Raw IMU data arrives at high rate and is expensive to fuse naively with lower-rate GNSS observables. A preintegration block provides a structured way to compress that information over intervals while keeping timing and bias assumptions explicit.

## Typical Use Cases

- Bridging GNSS update gaps with high-rate inertial motion summaries.
- Feeding preintegrated inertial deltas into a fusion filter or smoother.
- Supporting offline replay and deterministic hardware timing for inertial aggregation.
- Reducing host bandwidth by exporting interval summaries instead of every IMU sample.

## Interfaces and Signal-Level Behavior

- Inputs are timestamped gyro and accelerometer samples plus interval boundary events.
- Outputs provide integrated deltas, interval timestamps, validity flags, and possibly covariance or quality summaries.
- Control registers set integration interval policy, bias-compensation mode, and frame conventions.
- Diagnostic outputs may expose sample counts, saturation events, and residual timing error inside the interval.

## Parameters and Configuration Knobs

- Sensor sample width and internal accumulator precision.
- Maximum interval length and supported sample counts per interval.
- Bias and scale compensation support.
- Coordinate-frame convention and gravity-handling mode.

## Internal Architecture and Dataflow

A typical block contains sample accumulation, bias application, interval bookkeeping, and output formatting. The contract should be clear about frame conventions and whether gravity compensation is applied internally, because those choices change the meaning of the resulting deltas.

## Clocking, Reset, and Timing Assumptions

The module assumes a trustworthy IMU time base and known sample ordering. Reset clears any partial interval. If bias estimates are injected from outside, updates should occur only at safe interval boundaries or be version-tagged to avoid mixing states.

## Latency, Throughput, and Resource Considerations

Throughput must match the raw IMU sample rate continuously. Resource use depends mainly on accumulator precision and any covariance tracking included. Latency is interval-based, which is acceptable so long as the end-of-interval semantics are deterministic.

## Verification Strategy

- Replay known inertial trajectories and compare preintegrated deltas against a software reference.
- Stress saturation, missing-sample, and jittered-timestamp cases.
- Verify bias-update handling at interval boundaries.
- Check coordinate-frame conventions using simple canonical motions such as pure rotation or constant acceleration.

## Integration Notes and Dependencies

IMU Preintegration feeds Kalman Fusion Engine and can assist Dead Reckoning Block or Strapdown Integrator depending on system partitioning. It should share timestamp and frame conventions with all navigation consumers.

## Edge Cases, Failure Modes, and Design Risks

- A frame-convention mismatch can silently flip axes or signs in the fusion pipeline.
- Mixing bias states within one interval can make preintegrated deltas internally inconsistent.
- If interval boundaries drift from the GNSS measurement cadence, fusion alignment suffers.

## Related Modules In This Domain

- kalman_fusion_engine
- strapdown_integrator
- dead_reckoning_block
- timestamp_synchronizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the IMU Preintegration module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
