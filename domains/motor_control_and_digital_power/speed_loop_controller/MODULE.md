# Speed Loop Controller

## Overview

Speed Loop Controller regulates measured motor speed to a target by producing torque-producing current or equivalent actuation demand for the inner loop. It is the supervisory loop responsible for commanded acceleration and speed holding.

## Domain Context

The speed loop is the slower outer loop that turns a speed command into the current or torque request consumed by the inner FOC current loop. In a motor-control hierarchy it is the layer that shapes macroscopic motion while delegating fast electrical dynamics to the inner loop.

## Problem Solved

Directly commanding current without an outer loop leaves speed control to software heuristics or operator guesswork. A dedicated speed controller formalizes speed regulation, limit handling, and interaction with the fast current loop.

## Typical Use Cases

- Holding commanded shaft speed under varying load torque.
- Producing q-axis current references for a PMSM or BLDC drive.
- Implementing acceleration limiting and speed ramps for safe motion control.
- Supporting operating modes such as velocity hold, coast, or regenerative braking limits.

## Interfaces and Signal-Level Behavior

- Inputs include target speed, measured speed, enable state, and operating limits such as current or torque caps.
- Outputs provide current or torque reference commands plus status such as saturation or at-speed indication.
- Control registers configure PI gains, ramp limits, anti-windup, and braking or reverse policies.
- Diagnostic outputs may expose speed error, integrator state, and command limiting activity.

## Parameters and Configuration Knobs

- Speed measurement precision and reference scaling.
- PI coefficient precision and update period.
- Acceleration and jerk limiting support.
- Current or torque limit range and sign policy.

## Internal Architecture and Dataflow

The loop typically uses PI regulation with optional ramp generation, limit handling, and supervisory mode logic. The contract should define exactly what the output means, such as q-axis current reference or normalized torque demand, so the inner loop and higher-level motion logic interpret it consistently.

## Clocking, Reset, and Timing Assumptions

Measured speed is assumed to be filtered or estimated appropriately for the chosen loop bandwidth. Reset clears integrator and ramp state. If mode changes such as reverse or braking are supported, their transition rules should be explicit to avoid discontinuous torque commands.

## Latency, Throughput, and Resource Considerations

The speed loop runs much slower than the current loop, so resource cost is low. The key performance attributes are well-defined saturation behavior and stable interaction with the faster inner current loop. Latency should be bounded but is not usually the limiting factor.

## Verification Strategy

- Check speed step, ramp, and disturbance response against a plant or reference controller.
- Stress current limiting, anti-windup, and direction reversals.
- Verify interaction with the inner current loop under saturation.
- Confirm at-speed and fault-inhibit status behave consistently across operating modes.

## Integration Notes and Dependencies

Speed Loop Controller typically consumes Speed Observer or sensor-decoder output and drives the q-axis reference of the FOC Current Loop. It also coordinates with Soft Start Controller and fault logic so torque demand ramps safely after enable.

## Edge Cases, Failure Modes, and Design Risks

- An outer loop that ignores inner-loop limits can wind up badly and recover slowly.
- Noisy or delayed speed feedback can make the loop hunt or oscillate.
- If the output semantic is unclear, different teams may scale torque demand inconsistently.

## Related Modules In This Domain

- speed_observer
- foc_current_loop
- soft_start_controller
- quadrature_encoder_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Speed Loop Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
