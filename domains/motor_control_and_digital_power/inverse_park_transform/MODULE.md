# Inverse Park Transform

## Overview

Inverse Park Transform rotates d-q frame command quantities back into alpha-beta stationary-frame components using the electrical angle estimate. It translates controller outputs into the vector form needed for modulation.

## Domain Context

Inverse Park completes the frame conversion loop by mapping d-q voltage or current commands back into the stationary alpha-beta frame for modulation and drive generation. It is the bridge from decoupled control outputs to physically realizable inverter commands.

## Problem Solved

FOC regulators naturally compute commands in the rotor frame, but the PWM and inverter logic operate in stationary coordinates. A dedicated inverse transform ensures that handoff is mathematically consistent and predictable.

## Typical Use Cases

- Converting d-q voltage commands into alpha-beta vectors for SVPWM.
- Projecting torque and flux control outputs back into the inverter frame.
- Supporting debug comparisons between rotating-frame control and stationary-frame modulation.
- Providing stationary-frame command vectors to observers or feedforward blocks.

## Interfaces and Signal-Level Behavior

- Inputs are d-q commands, electrical angle, and validity metadata.
- Outputs provide alpha-beta components with aligned valid signaling.
- Control registers may select angle source, scaling, and sign convention.
- Diagnostic outputs can expose transformed vector magnitude or clipping flags.

## Parameters and Configuration Knobs

- Numeric precision for command inputs and vector outputs.
- Angle resolution and sine-cosine source mode.
- Axis and rotation-sign conventions.
- Optional output limiting or saturation reporting.

## Internal Architecture and Dataflow

The block is usually the complementary rotation matrix to the Park transform and should be implemented with matching trig and scaling conventions. The contract should emphasize that it is not merely similar to Park but mathematically paired with it, because consistency between the two determines control fidelity.

## Clocking, Reset, and Timing Assumptions

The electrical angle used here must be the same effective angle used by the current feedback path or else the control loop becomes inconsistent. Reset clears only transient pipeline state. Any output clipping should be visible to later voltage-limiting or anti-windup logic.

## Latency, Throughput, and Resource Considerations

Cost and latency are similar to Park Transform. Deterministic timing is important because modulation update boundaries are strict. Precision affects how smoothly commanded vectors rotate near high speed and field-weakening boundaries.

## Verification Strategy

- Run round-trip tests with Park Transform to confirm convention consistency.
- Verify output vector orientation for known d-q inputs and angles.
- Stress angle wraparound, saturation, and invalid-angle handling.
- Compare against a floating-point control reference under dynamic command sweeps.

## Integration Notes and Dependencies

Inverse Park Transform usually feeds Space Vector PWM and may work alongside feedforward or decoupling terms from the current loop. It should remain convention-aligned with the Park Transform, observer angle source, and modulation scaling.

## Edge Cases, Failure Modes, and Design Risks

- A mismatch with the forward transform can create subtle but severe control cross-coupling.
- Hidden clipping can trigger unexplained anti-windup or torque saturation behavior.
- If angle timing is stale relative to current feedback, dynamic performance degrades sharply.

## Related Modules In This Domain

- park_transform
- space_vector_pwm
- foc_current_loop
- flux_observer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Inverse Park Transform module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
