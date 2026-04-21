# Pwm Generator

## Overview

pwm_generator creates pulse-width modulated outputs with configurable period, duty cycle, and often polarity or dead-time related options. It is the generic digital drive primitive for simple actuators, indicators, and control outputs.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

PWM is easy to sketch but easy to mishandle around update timing, resolution, polarity, and glitch-free reconfiguration. pwm_generator provides one reusable contract for those behaviors.

## Typical Use Cases

- Drive LEDs, fans, servos, or simple power-control inputs.
- Provide a duty-controlled digital output for embedded control loops.
- Generate timing-qualified enables for external devices.

## Interfaces and Signal-Level Behavior

- Inputs usually include period, duty value, enable, and optional phase or polarity controls.
- Outputs are one or more PWM waveforms plus optional update or period-complete status.
- Some variants also expose fault-disable or sync inputs.

## Parameters and Configuration Knobs

- COUNTER_WIDTH sets timing resolution.
- CENTER_ALIGNED_EN enables symmetric counting if supported.
- POLARITY_MODE selects active-high or active-low output.
- SHADOW_UPDATE_EN applies new settings at a safe boundary.
- MULTI_CHANNEL_EN scales the block to several related outputs.

## Internal Architecture and Dataflow

A PWM generator usually compares a running counter against a duty threshold and updates outputs accordingly. The subtle behavior lies in when new duty or period values take effect and whether waveform changes can occur glitch-free at period boundaries.

## Clocking, Reset, and Timing Assumptions

Consumers often treat PWM outputs as real actuating signals, so reset and enable defaults matter physically. If center-aligned or synchronized updates are supported, the host must know exactly when changes become active.

## Latency, Throughput, and Resource Considerations

PWM logic is lightweight. The relevant metrics are resolution, maximum frequency, and glitch-free update behavior rather than throughput. Multi-channel variants add mostly replicated compare logic.

## Verification Strategy

- Check period and duty behavior across the full configured range.
- Verify 0 percent and 100 percent corner cases.
- Exercise shadow or synchronized updates mid-period.
- Confirm polarity, enable, and fault-disable behavior.

## Integration Notes and Dependencies

pwm_generator often pairs with GPIO control, control loops, and software-facing CSRs. It should document whether it is intended for generic IO modulation or for more timing-sensitive actuator drive.

## Edge Cases, Failure Modes, and Design Risks

- Update timing that is not explicit can create visible glitches or unstable control behavior.
- Reset output state is often a board-level concern.
- Counter and compare off-by-one errors show up at the ends of the duty range.

## Related Modules In This Domain

- gpio_bank
- pulse_capture
- timer_block
- quadrature_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pwm Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
