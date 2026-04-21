# PFC Controller

## Overview

PFC Controller regulates a power-factor-correction stage by shaping input current and maintaining bus voltage according to configured control strategy. It is the front-end power-conditioning loop for AC-fed digital power systems.

## Domain Context

Power-factor correction control appears alongside motor and power-conversion subsystems in many embedded power platforms. It regulates the front-end converter so line current follows the input voltage waveform while maintaining the desired DC bus.

## Problem Solved

An AC front end cannot simply rectify and hope for acceptable line behavior. Without a dedicated PFC control block, bus regulation, harmonic performance, and line-current shaping are left to ad hoc software or analog glue, reducing efficiency and compliance confidence.

## Typical Use Cases

- Controlling a boost PFC stage feeding a motor-drive DC bus.
- Maintaining bus voltage while shaping line current sinusoidally.
- Supporting lab evaluation of different digital PFC compensation strategies.
- Coordinating front-end power-stage behavior with downstream inverter demand.

## Interfaces and Signal-Level Behavior

- Inputs include bus-voltage feedback, line-voltage or line-phase information, current feedback, and enable or fault state.
- Outputs provide duty or current-reference commands to the PWM stage plus loop-status indicators.
- Control registers configure voltage and current loop gains, feedforward modes, and protection thresholds.
- Diagnostic outputs may expose instantaneous current reference, loop error, and saturation or brownout status.

## Parameters and Configuration Knobs

- Voltage and current control precision and gain scaling.
- Line-frequency tracking or feedforward configuration.
- Bus-voltage target range and current-limit settings.
- Supported topology assumptions such as boost PFC timing model.

## Internal Architecture and Dataflow

A digital PFC controller commonly combines an outer bus-voltage loop with an inner current-shaping loop and duty-limiting logic. The contract should explain what measurements are required and what topology is assumed, because those details determine whether the controller is even applicable to a given hardware front end.

## Clocking, Reset, and Timing Assumptions

The block assumes appropriately filtered measurements of line and bus quantities, and a switching stage that responds predictably at the configured rate. Reset should force zero drive. If line phase is inferred rather than measured directly, that assumption should be visible to integrators.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is moderate. Timing matters because current shaping is tied to switching cadence and line phase. Numeric saturation and anti-windup behavior are often more important than elaborate math when it comes to practical stability.

## Verification Strategy

- Check closed-loop regulation and current-shaping behavior against a converter model or reference controller.
- Stress line-voltage variation, load steps, and brownout conditions.
- Verify limit handling and protection interaction during startup and overload.
- Compare digital loop behavior with expected bus ripple and current harmonic performance targets.

## Integration Notes and Dependencies

PFC Controller typically works with PWM generation, Soft Start Controller, and Overcurrent Shutdown while supplying the DC bus used by later motor or power stages. It should coordinate with bus-voltage sensing used by downstream motor modulation blocks.

## Edge Cases, Failure Modes, and Design Risks

- A poorly scaled inner current loop can distort line current and defeat the purpose of PFC.
- If startup sequencing is not coordinated with downstream bus demand, nuisance trips or bus droop can occur.
- Topology assumptions that are left implicit can lead to incorrect reuse on incompatible hardware.

## Related Modules In This Domain

- center_aligned_pwm
- soft_start_controller
- overcurrent_shutdown
- smps_digital_compensator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PFC Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
