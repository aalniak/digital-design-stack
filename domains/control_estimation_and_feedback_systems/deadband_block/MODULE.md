# Deadband Block

## Overview

The deadband block suppresses small control errors or command variations within a configured region so the loop ignores insignificant noise and avoids unnecessary actuator chatter. It is a simple but often important practical-conditioning element in real control systems.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Sensors and references are noisy, and some actuators wear out or hunt if commanded for tiny meaningless changes. A deadband gives the loop a tolerance zone, but that tolerance must be explicit and deterministic rather than hidden inside ad hoc logic. This module provides that behavior cleanly.

## Typical Use Cases

- Reducing actuator chatter around zero error in servo or valve control.
- Filtering small command fluctuations caused by sensor noise.
- Providing a reusable tolerance element in industrial and instrumentation loops.

## Interfaces and Signal-Level Behavior

- Input side accepts the signal or error to be deadbanded.
- Output side emits the unchanged signal outside the band and a suppressed or modified value inside it.
- Control side sets the deadband width, center, and optional hysteresis or offset behavior.

## Parameters and Configuration Knobs

- Input width, deadband thresholds, and hysteresis enable.
- Centered versus asymmetric band behavior and output shaping inside the band.
- Optional runtime update support and signedness assumptions.

## Internal Architecture and Dataflow

The block compares the incoming value against configured thresholds and either passes it through, clips it to zero, or applies a small offset depending on the selected mode. Variants with hysteresis remember which side of the band the signal last occupied so noise near the boundary does not cause rapid toggling. The important contract point is what exact output is produced inside the deadband.

## Clocking, Reset, and Timing Assumptions

The chosen deadband must be meaningful in the same numeric units as the surrounding loop. Reset should establish a deterministic hysteresis state if hysteresis is enabled.

## Latency, Throughput, and Resource Considerations

Deadband logic is trivial in computational cost and normally adds almost no latency. It is primarily a policy and integration block rather than a throughput block.

## Verification Strategy

- Check entry and exit behavior at both deadband boundaries including exact threshold equality.
- Verify hysteresis behavior under noisy signals near the threshold.
- Confirm runtime threshold updates do not create unexpected discontinuities.

## Integration Notes and Dependencies

This block is often placed before a controller or actuator interface, and that placement changes its effect. Integrators should document whether the deadband is intended to ignore sensor noise, command noise, or actuator wear concerns.

## Edge Cases, Failure Modes, and Design Risks

- A deadband that is too wide can hide meaningful small errors and create steady-state bias.
- If the output inside the band is not clearly defined, different teams may assume different loop behavior.
- Asymmetric thresholds can introduce directional bias that is easy to overlook.

## Related Modules In This Domain

- limiter_block
- pi_controller
- setpoint_ramp

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Deadband Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
