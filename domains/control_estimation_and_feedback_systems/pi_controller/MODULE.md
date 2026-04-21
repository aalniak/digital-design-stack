# PI Controller

## Overview

The PI controller combines proportional and integral action to regulate a signal with both transient responsiveness and zero or low steady-state error. It is one of the most widely reused closed-loop building blocks in digital systems.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Many plants need more than pure proportional gain to eliminate persistent bias, but implementing integral action repeatedly invites inconsistency in scaling, update order, and saturation handling. This module provides a disciplined PI core with a documented numeric and timing contract.

## Typical Use Cases

- Current, speed, temperature, or power regulation loops.
- Embedded control systems that need robust steady-state accuracy with moderate complexity.
- Serving as a standard controller primitive underneath richer plant-specific wrappers.

## Interfaces and Signal-Level Behavior

- Input side accepts error or reference-minus-measurement values each control tick.
- Output side emits the commanded control effort and may expose internal integral state for monitoring.
- Control side sets proportional and integral gains, optional output limits, and enable or reset behavior.

## Parameters and Configuration Knobs

- Gain widths, integral-state precision, output width, and update cadence.
- Optional saturation handling, integrator limits, and coefficient reload behavior.
- Signedness and whether gains are fixed-point compile-time values or runtime-programmable.

## Internal Architecture and Dataflow

The controller computes a proportional term from the current error and integrates the error over time to form the integral term, then sums them into the output command. Practical designs define carefully whether limiting occurs before or after internal state update and whether anti-windup logic is internal or external. The module contract should also describe whether the output is updated synchronously with the input tick or registered one cycle later.

## Clocking, Reset, and Timing Assumptions

PI gain meaning depends on the control period and the scaling of the error signal, so those assumptions must remain visible. Reset should initialize the integrator in a documented state, usually zero or a known bias value for bumpless startup.

## Latency, Throughput, and Resource Considerations

PI controllers are low-cost control-rate modules. Numerical precision and update ordering matter far more than datapath throughput.

## Verification Strategy

- Compare step response and steady-state behavior against a discrete-time control reference.
- Check gain reloads, output limiting, and integrator reset behavior.
- Verify exact update ordering so external anti-windup or monitoring logic sees the expected state transitions.

## Integration Notes and Dependencies

This block usually sits at the center of a plant-specific loop, so the surrounding design should document signal units, control period, and any feedforward or limiting around it. Integrators should also note whether anti-windup is handled inside the controller or by a separate module.

## Edge Cases, Failure Modes, and Design Risks

- Gains that are valid in one sample period may destabilize the loop at another.
- If output limiting and integrator updates are ordered ambiguously, field tuning becomes confusing.
- Poor fixed-point scaling can make the integrator too coarse to remove steady-state error.

## Related Modules In This Domain

- pid_controller
- anti_windup_block
- limiter_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PI Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
