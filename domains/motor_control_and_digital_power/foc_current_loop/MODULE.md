# FOC Current Loop

## Overview

FOC Current Loop computes d-q voltage commands from d-q current feedback and current setpoints, typically using PI regulation plus optional decoupling and feedforward terms. It is the main closed-loop actuator in field-oriented control.

## Domain Context

The FOC current loop is the high-bandwidth control core of many modern motor drives. It regulates d-axis and q-axis current toward commanded targets, effectively controlling flux and torque in the rotating frame.

## Problem Solved

Once currents are expressed in the rotating frame, they still need a disciplined controller that respects loop timing, voltage limits, and cross-axis coupling. A dedicated current-loop block makes those behaviors explicit rather than scattering them across software or generic arithmetic blocks.

## Typical Use Cases

- Regulating torque-producing q-axis current in a PMSM drive.
- Maintaining d-axis current for flux control or field weakening.
- Applying decoupling and bus-voltage feedforward in high-performance drives.
- Serving as the fast inner loop beneath a slower speed regulator.

## Interfaces and Signal-Level Behavior

- Inputs include measured d-q currents, d-q current references, bus-voltage context, and control-enable signals.
- Outputs provide d-q voltage commands, saturation indicators, and loop-state diagnostics.
- Control registers configure PI gains, anti-windup policy, decoupling enable, and current limits.
- Diagnostic outputs may expose error terms, integrator states, and limiter engagement flags.

## Parameters and Configuration Knobs

- Current and voltage numeric precision.
- PI coefficient width and scaling.
- Anti-windup and saturation strategy.
- Optional cross-coupling compensation and feedforward support.

## Internal Architecture and Dataflow

A typical implementation contains parallel d-axis and q-axis regulators, optional decoupling feedforward, limit management, and integrator anti-windup. The critical contract is how saturation is handled, because torque response and loop stability depend strongly on whether both axes are clipped independently, vector-limited, or coordinated with higher loops.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed already transformed into a consistent d-q frame and sampled once per control interval. Reset clears integrators and disables actuation until re-enabled. If bus-voltage compensation is used, the measurement must align closely enough in time to the modulation cycle to remain meaningful.

## Latency, Throughput, and Resource Considerations

This is a timing-sensitive control block whose latency must fit within the PWM update window. Arithmetic cost is moderate. Dynamic performance depends on coefficient scaling, saturation handling, and deterministic control cadence more than sheer computational complexity.

## Verification Strategy

- Check step response and stability against a plant or reference controller model.
- Stress saturation, anti-windup, and field-weakening boundary conditions.
- Verify sign conventions and decoupling terms on both axes.
- Measure closed-loop timing from current sample arrival to voltage-command update.

## Integration Notes and Dependencies

FOC Current Loop consumes Park-transformed current feedback and usually feeds Inverse Park Transform, with Speed Loop Controller setting the q-axis reference. It must integrate tightly with Current Reconstruction, PWM timing, and flux or position observers.

## Edge Cases, Failure Modes, and Design Risks

- Axis sign mistakes or swapped d and q channels can produce unstable or reversed torque behavior.
- Poor anti-windup design can cause sluggish recovery after saturation.
- A loop that is numerically correct but late by one PWM cycle may perform far worse than expected.

## Related Modules In This Domain

- park_transform
- inverse_park_transform
- speed_loop_controller
- flux_observer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the FOC Current Loop module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
