# Park Transform

## Overview

Park Transform converts alpha-beta vector quantities into d-q rotating-frame components using the current electrical angle estimate. It gives the controller direct access to flux-producing and torque-producing axes.

## Domain Context

The Park transform rotates stationary alpha-beta quantities into the rotor-aligned d-q frame where torque and flux can be regulated more independently. In field-oriented control it is one of the key steps that turns AC motor behavior into something resembling decoupled DC control channels.

## Problem Solved

Even after Clarke projection, the motor variables still rotate with the rotor field. A dedicated Park transform is needed so current loops can regulate nearly constant quantities aligned with the machine flux rather than chasing rotating sinusoids.

## Typical Use Cases

- Converting measured alpha-beta currents into d-q current feedback for FOC.
- Projecting voltage commands into the rotating frame for decoupled control calculations.
- Supporting rotor-flux-aligned control of PMSM or AC induction machines.
- Providing d-q quantities to observers and diagnostics.

## Interfaces and Signal-Level Behavior

- Inputs are alpha-beta signals, electrical angle, and validity information.
- Outputs provide d and q components aligned to the supplied angle.
- Control interfaces may select sine-cosine source, angle scaling, and transform convention.
- Diagnostic outputs can expose angle-valid status or transform saturation flags.

## Parameters and Configuration Knobs

- Input and output precision plus angle resolution.
- Rotation convention and sign selection for q-axis orientation.
- Support for pipelined sine-cosine lookup versus externally supplied trig values.
- Optional magnitude-clipping behavior for extreme inputs.

## Internal Architecture and Dataflow

Implementation generally uses the supplied sine and cosine values in a small rotation matrix. The contract should document axis orientation and angle convention clearly, because a 90-degree or sign error here changes torque sign or cross-couples the controller badly.

## Clocking, Reset, and Timing Assumptions

The electrical angle source must be coherent with the actual machine position or observer estimate. Reset clears pipeline state but does not establish a meaningful operating angle by itself. If sine and cosine are supplied externally, they are assumed normalized consistently with the transform math.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is moderate and fixed. Latency must fit within the current-loop budget and remain predictable. Numeric precision of the angle and trig path often matters more than additional datapath width elsewhere.

## Verification Strategy

- Compare d-q outputs against a floating-point reference for multiple vector angles and magnitudes.
- Verify sign and orientation conventions using simple known vectors.
- Stress angle wraparound and invalid-angle cases.
- Check consistency with Inverse Park Transform by running round-trip vector tests.

## Integration Notes and Dependencies

Park Transform sits between Clarke Transform and the FOC Current Loop, and often shares the same angle source with Inverse Park Transform and observers. All consuming blocks must agree on the same electrical-angle convention.

## Edge Cases, Failure Modes, and Design Risks

- A sign or angle convention mismatch here can reverse torque command or destabilize decoupling.
- Poor trig precision can show up as ripple or cross-axis coupling under load.
- If angle validity is ignored, the controller may act on meaningless transformed currents.

## Related Modules In This Domain

- clarke_transform
- inverse_park_transform
- foc_current_loop
- speed_observer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Park Transform module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
