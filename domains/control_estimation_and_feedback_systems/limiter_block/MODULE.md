# Limiter Block

## Overview

The limiter block constrains a signal to configured bounds and optionally reports when limiting occurs. It is one of the simplest practical control primitives, but it often determines whether the rest of the loop behaves like the designer expects.

## Domain Context

Control, estimation, and feedback modules close loops around plant dynamics, sensors, and reference trajectories. In this domain the critical documentation topics are state update timing, saturation behavior, stability assumptions, fixed-point scaling, and how asynchronous events such as resets or coefficient changes interact with the loop state.

## Problem Solved

Real actuators, references, and intermediate states cannot take arbitrary values. Those constraints need to be explicit rather than scattered across ad hoc clamp logic. This module centralizes signal limiting and makes saturation visible to the rest of the design.

## Typical Use Cases

- Clamping actuator commands to safe physical limits.
- Restricting intermediate controller outputs or references.
- Providing reusable bounded-signal behavior to support anti-windup and safety logic.

## Interfaces and Signal-Level Behavior

- Input side accepts the value to be constrained.
- Output side emits the limited value and often a high-limit or low-limit hit flag.
- Control side sets upper and lower bounds and optional asymmetry or dynamic limit update behavior.

## Parameters and Configuration Knobs

- Signal width, bound width, and signedness.
- Static versus runtime-programmable limits and optional hysteresis or flag latching.
- Saturation versus wrap policy if several modes are supported.

## Internal Architecture and Dataflow

The limiter compares the incoming value against configured bounds and outputs the appropriate clipped or pass-through value. Some variants also report whether the signal was limited so surrounding controllers can adjust their internal state. The contract should define clearly how exact-threshold equality is handled and whether flag outputs are pulse or level based.

## Clocking, Reset, and Timing Assumptions

Limit values must be expressed in the same units and scaling as the signal they bound. Reset should initialize flags and internal state consistently if latching or hysteresis is used.

## Latency, Throughput, and Resource Considerations

Limiters are tiny and effectively instantaneous relative to most control loops. Their practical importance comes from policy clarity, not arithmetic complexity.

## Verification Strategy

- Check lower-bound, upper-bound, and in-range behavior including equality at thresholds.
- Verify flag semantics and runtime bound updates.
- Confirm downstream modules such as anti-windup logic receive the documented saturation information.

## Integration Notes and Dependencies

This block often sits next to actuators, profile generators, and controllers, and the exact placement matters. Integrators should document whether the limited signal or the pre-limit signal is considered the commanded effort elsewhere in the system.

## Edge Cases, Failure Modes, and Design Risks

- If bound units are inconsistent with the signal units, the limiter can silently distort the loop.
- Missing or ambiguous saturation flags reduce the value of anti-windup and fault logic.
- Dynamic limit changes can create command discontinuities if not coordinated with the rest of the loop.

## Related Modules In This Domain

- anti_windup_block
- deadband_block
- pid_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Limiter Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
