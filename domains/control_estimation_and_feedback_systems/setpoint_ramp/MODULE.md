# Setpoint Ramp

## Overview

The setpoint ramp module limits how quickly a commanded reference changes, turning abrupt operator or software requests into smoother ramps that are easier for the loop and plant to follow. It is a simple but often essential reference-conditioning block.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Controllers and plants frequently respond poorly to instantaneous setpoint steps, especially when actuators saturate or operators want predictable behavior. A setpoint ramp introduces explicit slew limits so commands change at a controlled pace instead of depending on ad hoc software timing.

## Typical Use Cases

- Soft-starting references for power, motion, or thermal loops.
- Reducing overshoot caused by abrupt setpoint changes.
- Providing consistent operator-command conditioning across products or experiments.

## Interfaces and Signal-Level Behavior

- Input side accepts the target setpoint value.
- Output side emits the ramped reference and may indicate when the target has been reached.
- Control side configures positive and negative slew limits, hold behavior, and reset policy.

## Parameters and Configuration Knobs

- Setpoint width, per-tick rise and fall limits, and signedness.
- Target-update policy during an active ramp and optional reached-target flag behavior.
- Runtime limit updates and whether ramping can be paused or bypassed.

## Internal Architecture and Dataflow

At each update tick the block compares the current output reference against the desired target and advances by at most the configured limit in the required direction. Some versions use separate rise and fall limits or additional hold logic. The documentation should state how target changes during an active ramp are handled and whether the output snaps on reset or restarts from zero.

## Clocking, Reset, and Timing Assumptions

The slew-rate values are meaningful only with respect to the control tick period, so time-base assumptions must be documented. Reset should define the initial output and target tracking policy clearly.

## Latency, Throughput, and Resource Considerations

This is trivial control-rate arithmetic with negligible resource cost. The value lies in making command shaping explicit and repeatable.

## Verification Strategy

- Check rise, fall, and steady-state hold behavior for positive and negative commands.
- Verify retargeting while a ramp is in progress.
- Confirm reached-target flags and reset policy behave as documented.

## Integration Notes and Dependencies

Setpoint ramps usually precede controllers or profile generators, and the exact placement changes system behavior. Integrators should document whether the ramp is meant as a simple operator safeguard or as part of the formal closed-loop design.

## Edge Cases, Failure Modes, and Design Risks

- If the ramp limit is too small, the loop may appear sluggish for reasons unrelated to controller tuning.
- A reset policy that snaps the reference unexpectedly can defeat the purpose of ramping.
- Asymmetric rise and fall limits may create operator confusion if not documented clearly.

## Related Modules In This Domain

- jerk_limited_profile
- trajectory_generator
- deadband_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Setpoint Ramp module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
