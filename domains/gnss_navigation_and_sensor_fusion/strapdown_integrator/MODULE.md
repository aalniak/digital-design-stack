# Strapdown Integrator

## Overview

Strapdown Integrator integrates IMU data over time to propagate the navigation state of the platform in a defined reference frame. It provides the predicted motion state that later measurements correct.

## Domain Context

The strapdown integrator is the continuous navigation propagation core that turns inertial measurements into evolving attitude, velocity, and position states in the chosen navigation frame. It is fundamental to inertial navigation and often provides the propagation step for fusion filters.

## Problem Solved

Inertial sensors report body-frame rotation and acceleration, not directly usable position or attitude. A dedicated strapdown block is needed to manage coordinate transforms, gravity handling, and continuous state propagation without leaving those critical conventions implicit.

## Typical Use Cases

- Propagating attitude, velocity, and position between GNSS updates.
- Providing dead-reckoned state during temporary GNSS outages.
- Serving as the prediction step inside a tightly coupled navigation filter.
- Generating continuous orientation and motion telemetry for a robotic or aerospace platform.

## Interfaces and Signal-Level Behavior

- Inputs include timestamped IMU samples, initial state, and optional bias or correction terms from a fusion filter.
- Outputs provide propagated attitude, velocity, position, and state-valid indicators.
- Control registers configure reference frame, gravity model, and numeric representation.
- Diagnostic outputs may expose intermediate rotation states, integration counters, and fault flags for out-of-range values.

## Parameters and Configuration Knobs

- State precision and quaternion or rotation-matrix representation.
- Reference frame convention and gravity model support.
- Update cadence and maximum sample interval.
- Optional compensation inputs for bias, lever arm, or aiding corrections.

## Internal Architecture and Dataflow

The integrator usually contains attitude propagation, specific-force transformation into navigation coordinates, gravity compensation, and velocity and position integration. The documentation should define the state convention explicitly, including axis orientation and whether outputs are Earth-fixed, local-level, or another frame.

## Clocking, Reset, and Timing Assumptions

It assumes IMU timing is monotonic and the initial state is valid in the chosen frame. Reset clears propagation history and requires explicit state reinitialization. If correction terms arrive asynchronously from a filter, the application point in the propagation cycle must be documented.

## Latency, Throughput, and Resource Considerations

This block runs at IMU rate, so throughput must comfortably sustain worst-case sensor frequency. Resource use depends on numeric precision and the chosen rotation representation. Deterministic update ordering is essential to keep propagation repeatable.

## Verification Strategy

- Replay canonical inertial trajectories and compare propagated state against a reference INS model.
- Check gravity compensation and coordinate-frame conventions using stationary and constant-rate motion cases.
- Stress long-duration propagation to evaluate numeric drift and accumulator behavior.
- Verify correction injection points using synthetic bias or attitude updates.

## Integration Notes and Dependencies

Strapdown Integrator works closely with IMU Preintegration, Dead Reckoning Block, and Kalman Fusion Engine. It should share state conventions with every consumer, because frame mismatches here invalidate the entire navigation chain.

## Edge Cases, Failure Modes, and Design Risks

- A sign or axis convention error can survive unit tests but devastate real-world navigation.
- Poor numeric precision can cause long-term drift far beyond what the filter expects.
- Applying corrections at undocumented points in the update cycle makes reproduction and debugging very difficult.

## Related Modules In This Domain

- imu_preintegration
- kalman_fusion_engine
- dead_reckoning_block
- disciplined_clock_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Strapdown Integrator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
