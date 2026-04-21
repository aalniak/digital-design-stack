# Trajectory Generator

## Overview

The trajectory generator computes time-evolving reference commands such as position, velocity, or acceleration targets that move the system from one operating point to another in a controlled manner. It is the higher-level motion or command-planning counterpart to a simple ramp.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Many systems need structured motion or operating trajectories rather than instantaneous setpoint changes. Generating those trajectories repeatedly in software or ad hoc RTL leads to inconsistent timing, limit handling, and state reporting. This module provides a reusable planning block for reference evolution.

## Typical Use Cases

- Planning motion references for servo or robotics subsystems.
- Generating bounded operating trajectories for test equipment or process-control sequences.
- Serving as a reusable command-planning layer above lower-level controllers.

## Interfaces and Signal-Level Behavior

- Input side accepts target commands, mode changes, and possibly waypoints or segment parameters.
- Output side emits current trajectory state such as position, velocity, and acceleration references.
- Control side configures kinematic limits, trajectory mode, and pause, abort, or completion behavior.

## Parameters and Configuration Knobs

- Reference width, velocity and acceleration limits, and update cadence.
- Trajectory mode such as trapezoidal, bounded-acceleration, or custom segmented behavior.
- Optional reporting fields and support for mid-trajectory retargeting.

## Internal Architecture and Dataflow

The block updates internal motion state each control tick according to the configured trajectory law and current target. Compared with a simple setpoint ramp it often tracks several related state variables at once and may plan segment transitions explicitly. The documentation should state which outputs are authoritative and whether the module guarantees continuity of position alone or also of velocity and acceleration.

## Clocking, Reset, and Timing Assumptions

Limit values must share units and timing with the rest of the motion subsystem, so the sample-period assumption is central. Reset should define whether outputs restart from zero, hold present state, or require external initialization.

## Latency, Throughput, and Resource Considerations

Trajectory generation is modest in arithmetic cost and runs at the control rate. Deterministic state transitions matter more than throughput.

## Verification Strategy

- Compare generated references against a trajectory reference model over several move sizes and retarget scenarios.
- Verify limit compliance, completion flags, and abort or pause behavior.
- Check continuity guarantees for position, velocity, and acceleration according to the documented mode.

## Integration Notes and Dependencies

This block normally sits above one or more controllers, so its state outputs should align with any controller feedforward expectations. Integrators should also document how operators or software are allowed to change targets during motion.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch in units or sample period can make trajectories physically unrealistic while numerically neat.
- Retargeting policy that is not explicit can introduce discontinuities at exactly the moments users care about most.
- If completion flags are asserted too early, downstream sequencing may start before the plant is ready.

## Related Modules In This Domain

- jerk_limited_profile
- setpoint_ramp
- pid_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Trajectory Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
