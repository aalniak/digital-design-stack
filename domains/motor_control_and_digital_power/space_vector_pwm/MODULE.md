# Space Vector PWM

## Overview

Space Vector PWM maps voltage-vector commands into three-phase duty cycles and switching intervals for an inverter. It is the modulation layer that connects continuous control outputs to realizable three-phase PWM timings.

## Domain Context

Space Vector PWM is the modulation strategy commonly paired with field-oriented control in three-phase motor drives. It turns requested alpha-beta or phase voltage commands into duty cycles that use the DC bus efficiently while controlling switching sequence and common-mode behavior.

## Problem Solved

Three independent duty commands are not the most efficient or controlled way to drive a three-phase bridge from vector-control outputs. SVPWM offers better bus utilization and structured switching patterns, but only if implemented with clear sector logic and timing rules.

## Typical Use Cases

- Generating inverter duty cycles from FOC voltage commands.
- Improving DC-bus utilization relative to simple sinusoidal PWM.
- Coordinating zero-vector placement to favor current sensing windows or EMI goals.
- Supporting research comparisons among modulation schemes in motor-control platforms.

## Interfaces and Signal-Level Behavior

- Inputs usually include alpha-beta voltage commands or equivalent normalized phase references, enable state, and bus-voltage scaling context.
- Outputs provide three phase duty values or switching intervals for the PWM stage.
- Control registers configure modulation limits, zero-vector strategy, overmodulation behavior, and update cadence.
- Diagnostic outputs may expose sector index, clipped-command flags, and normalized dwell times.

## Parameters and Configuration Knobs

- Numeric precision for voltage vector inputs and duty outputs.
- Support for linear modulation only or controlled overmodulation.
- Zero-vector placement mode and sector encoding.
- Update interface matched to the downstream PWM shadow-register scheme.

## Internal Architecture and Dataflow

A standard implementation includes sector determination, dwell-time computation, zero-vector allocation, and duty normalization. The contract should define clipping and saturation semantics clearly because current-loop behavior near the voltage limit depends on whether commands are proportionally scaled or hard-clipped.

## Clocking, Reset, and Timing Assumptions

SVPWM assumes its voltage commands are already in the correct rotating or stationary frame and scaled to available bus voltage. Reset should force outputs to zero modulation or a safe disabled state. If bus-voltage feedforward is used, timing of that measurement relative to the modulation update should be documented.

## Latency, Throughput, and Resource Considerations

Arithmetic cost is moderate, especially when high precision or overmodulation support is included. Throughput must sustain the control update rate and present stable duty values before the next PWM reload boundary.

## Verification Strategy

- Verify sector selection and dwell calculations across the full voltage command space.
- Check duty sum and saturation behavior near linear modulation limits.
- Stress command sign changes and zero crossings to ensure no discontinuities or illegal duty patterns occur.
- Compare generated duties against a trusted SVPWM model for multiple bus-voltage conditions.

## Integration Notes and Dependencies

Space Vector PWM usually follows Clarke and Park transform based FOC control outputs and feeds Center-Aligned PWM. It should align with current-sampling strategy, because zero-vector placement can materially affect Current Reconstruction quality.

## Edge Cases, Failure Modes, and Design Risks

- A sector-boundary bug can create abrupt torque ripple or audible artifacts.
- Undocumented clipping behavior can destabilize the current loop near voltage saturation.
- If bus-voltage scaling is stale, commanded torque may be inconsistent under supply variation.

## Related Modules In This Domain

- center_aligned_pwm
- clarke_transform
- park_transform
- foc_current_loop

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Space Vector PWM module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
