# Dead Reckoning Block

## Overview

Dead Reckoning Block propagates platform motion state using inertial and optional kinematic inputs when direct absolute navigation measurements are unavailable or intermittent. It provides continuity of motion estimation across sensor gaps.

## Domain Context

Dead reckoning provides a usable navigation estimate when external measurements are sparse, delayed, or absent. In a GNSS and sensor-fusion stack it often represents the pragmatic motion-propagation path used during outages or as a simpler aid alongside more sophisticated filters.

## Problem Solved

Platforms cannot always wait for the next GNSS fix or full filter update to know where they are moving. A dedicated dead-reckoning path offers a controlled fallback or assist mechanism, with explicit assumptions about drift and input reliance.

## Typical Use Cases

- Bridging short GNSS outages during urban canyon or indoor transitions.
- Combining wheel speed, heading, or inertial data into a continuity estimate.
- Providing a low-compute fallback when full fusion is not active.
- Supporting integrity monitoring by comparing dead-reckoned and fused trajectories.

## Interfaces and Signal-Level Behavior

- Inputs may include inertial deltas, wheel or odometry inputs, heading estimates, and occasional absolute resets or corrections.
- Outputs provide propagated pose or displacement estimate, validity state, and drift-quality indicators.
- Control registers define motion model, input weighting, and reset policy.
- Diagnostic outputs may expose drift counters, correction history, and rejected aiding inputs.

## Parameters and Configuration Knobs

- Supported input modalities such as IMU-only or IMU plus odometry.
- State precision, update cadence, and maximum outage interval assumptions.
- Drift model or covariance growth parameters.
- Reference frame and orientation representation.

## Internal Architecture and Dataflow

The module typically combines a motion propagator with optional auxiliary-input fusion and quality tracking. The contract should be honest about whether it is a simple kinematic propagator or a lightly filtered navigation estimator, because downstream consumers need to know how much trust to place in the result.

## Clocking, Reset, and Timing Assumptions

Dead reckoning assumes the chosen kinematic inputs remain available and valid during the gap it is intended to bridge. Reset clears trajectory continuity. If absolute corrections are injected, their application timing and persistence should be documented explicitly.

## Latency, Throughput, and Resource Considerations

Throughput requirements follow the fastest contributing input, often the IMU rate. Resource use is modest relative to a full fusion engine, which is one reason this block is attractive as a fallback path. Accuracy degradation over time, not arithmetic speed, is the dominant performance concern.

## Verification Strategy

- Replay outage scenarios and measure drift growth against expected bounds.
- Check behavior when auxiliary inputs disappear or become inconsistent.
- Verify absolute correction application and reset semantics.
- Compare dead-reckoned output with a higher-fidelity reference under representative vehicle motion profiles.

## Integration Notes and Dependencies

Dead Reckoning Block can consume IMU Preintegration or Strapdown Integrator outputs and may feed Kalman Fusion Engine as a prior, or act as a fallback output path itself. It should coordinate with system integrity logic so users know when the estimate is propagated only.

## Edge Cases, Failure Modes, and Design Risks

- If drift growth is understated, downstream systems may overtrust stale propagated state.
- Mixing incompatible input frames or sign conventions can create fast divergence during outages.
- Fallback logic that switches silently between fused and dead-reckoned outputs can confuse operators and logs.

## Related Modules In This Domain

- strapdown_integrator
- imu_preintegration
- kalman_fusion_engine
- pps_aligner

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Dead Reckoning Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
