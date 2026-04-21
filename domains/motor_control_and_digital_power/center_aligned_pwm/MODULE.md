# Center-Aligned PWM

## Overview

Center-Aligned PWM generates symmetric switching waveforms by comparing control commands against an up-down carrier or equivalent timing structure. It provides balanced PWM timing for half-bridge and multi-phase power stages.

## Domain Context

Center-aligned PWM is a core timing primitive in motor drives and digital power stages because it reduces harmonic content and provides symmetrical switching around the midpoint of the period. In FOC and inverter control stacks it is the practical waveform base onto which modulation strategies are built.

## Problem Solved

Edge-aligned PWM can introduce asymmetry, higher harmonic distortion, and less convenient current-sampling windows in motor drives. A dedicated center-aligned implementation ensures switching symmetry and gives current reconstruction and dead-time logic a stable temporal foundation.

## Typical Use Cases

- Driving three-phase inverter legs in field-oriented motor control.
- Generating symmetric duty cycles for lower harmonic distortion in power stages.
- Creating predictable ADC sampling windows near the PWM midpoint.
- Serving as the base carrier for space-vector or sinusoidal modulation schemes.

## Interfaces and Signal-Level Behavior

- Inputs typically include duty or compare values, enable signals, period settings, and fault overrides.
- Outputs provide phase PWM waveforms or compare events aligned to the center-based carrier.
- Status signals may expose period_boundary, compare_update_ack, and fault-active states.
- Optional sideband outputs provide sync pulses for ADC triggering or loop scheduling.

## Parameters and Configuration Knobs

- PWM counter width and switching period range.
- Number of output channels or phases.
- Shadow-register update policy and safe period-boundary reload mode.
- Polarity conventions and optional complementary output support.

## Internal Architecture and Dataflow

A typical implementation uses an up-down counter, compare units, update shadow registers, and output gating. The key contract is that command updates occur at documented carrier boundaries so switching symmetry is preserved and loop-driven duty changes do not glitch mid-period.

## Clocking, Reset, and Timing Assumptions

The PWM domain is usually the highest-integrity timing domain in the motor drive. Reset should force a known safe output state. If command values cross from a slower control loop, shadowing and synchronization must prevent half-updated compare words from reaching the power stage.

## Latency, Throughput, and Resource Considerations

Logic cost is low, but timing determinism is critical. The block must sustain the target switching frequency with precise compare timing and low jitter. Resource use scales modestly with channel count and sideband trigger support.

## Verification Strategy

- Check waveform symmetry and compare transitions across the full duty range.
- Verify shadow-register reload only occurs on allowed carrier boundaries.
- Stress enable, disable, and fault overrides at different carrier phases.
- Confirm ADC or sync triggers align to the documented point in the PWM cycle.

## Integration Notes and Dependencies

Center-Aligned PWM is upstream of Dead Time Inserter and often driven by Space Vector PWM or current-loop outputs. It should also coordinate with Current Reconstruction and ADC trigger logic because current sensing quality depends on exact switching timing.

## Edge Cases, Failure Modes, and Design Risks

- Mid-period compare updates can create asymmetrical pulses and unpredictable current ripple.
- A reset state that is not truly safe can turn into shoot-through or unintended torque.
- If trigger timing is underspecified, sensing and control loops may sample in noisy windows.

## Related Modules In This Domain

- dead_time_inserter
- space_vector_pwm
- current_reconstruction
- foc_current_loop

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Center-Aligned PWM module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
