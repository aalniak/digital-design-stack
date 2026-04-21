# SMPS Digital Compensator

## Overview

SMPS Digital Compensator applies a discrete-time control law to converter feedback and generates duty or control commands for a switched-mode power stage. It is the reusable regulation block behind digitally controlled buck, boost, or related converters.

## Domain Context

The digital compensator is the control-law core for switched-mode power supplies implemented in firmware or hardware logic. In mixed motor-and-power platforms it often shares the same timing and safety ecosystem as the motor-control loops while targeting converter regulation instead of electromechanical behavior.

## Problem Solved

Power-converter regulation requires carefully designed discrete compensation, saturation handling, and sampling assumptions. A dedicated digital compensator makes those control-law details explicit rather than burying them in one-off arithmetic chains.

## Typical Use Cases

- Regulating output voltage or current in a digital buck or boost converter.
- Evaluating compensator designs such as PI, PID, or biquad-based loops.
- Sharing a common control-law core across several power rails in one FPGA.
- Providing a documented foundation for loop-stability experimentation in research hardware.

## Interfaces and Signal-Level Behavior

- Inputs include sampled feedback quantities, reference commands, enable state, and optional feedforward inputs.
- Outputs provide control effort or duty command along with saturation and loop-status information.
- Control registers configure coefficients, output limits, anti-windup mode, and update timing.
- Diagnostic outputs may expose error terms, internal states, and clipped-output indicators.

## Parameters and Configuration Knobs

- Coefficient precision and filter order.
- Input and output numeric range plus limit settings.
- Update cadence and sample-to-actuate latency budget.
- Support for direct-form or implementation-specific control structures.

## Internal Architecture and Dataflow

The compensator typically contains error computation, discrete filter or controller arithmetic, limit handling, and state storage. The important contract is the exact difference equation or transfer form being implemented, because equivalent analog design intent can map poorly if the digital realization is ambiguous.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed sampled at the documented control cadence and scaled consistently with the configured coefficients. Reset clears controller state and should not leave stale integrator terms. If feedforward is supported, the timing and meaning of that feedforward signal should be explicit.

## Latency, Throughput, and Resource Considerations

Arithmetic cost depends on filter order and precision but is generally manageable. Latency from sample to control output is crucial for stability analysis, and deterministic timing matters more than shaving a few multipliers.

## Verification Strategy

- Compare closed-loop and open-loop behavior against a reference discrete-time model.
- Stress saturation and anti-windup with large reference steps and load disturbances.
- Verify coefficient reload and state-reset semantics.
- Check fixed-point overflow margins for representative converter operating ranges.

## Integration Notes and Dependencies

SMPS Digital Compensator typically feeds PWM logic and interacts with Soft Start Controller, Overcurrent Shutdown, and measurement front ends. It should align with board-level control analysis so implemented coefficients correspond to the intended power-stage plant.

## Edge Cases, Failure Modes, and Design Risks

- A subtle mismatch between documented and actual difference equation can invalidate stability analysis.
- Ignoring control latency in the design model can make a seemingly correct compensator unstable on hardware.
- Coefficient reload without safe boundaries can inject abrupt duty changes into the converter.

## Related Modules In This Domain

- center_aligned_pwm
- soft_start_controller
- overcurrent_shutdown
- pfc_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SMPS Digital Compensator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
