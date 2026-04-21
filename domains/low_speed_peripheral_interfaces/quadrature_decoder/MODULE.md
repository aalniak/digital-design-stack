# Quadrature Decoder

## Overview

quadrature_decoder interprets phased encoder inputs to produce position, direction, and often velocity-related information. It is the digital motion-sensing primitive for incremental encoders and similar sources.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

Quadrature signals look simple but contain edge-order, noise, and illegal-transition concerns that directly affect measured position. quadrature_decoder packages that interpretation into one reusable block.

## Typical Use Cases

- Track rotary or linear incremental encoder position.
- Provide direction and motion events to control loops.
- Measure mechanical movement using simple phased digital signals.

## Interfaces and Signal-Level Behavior

- External inputs typically include encoder phase A and B and optionally index or reference pulse.
- Outputs include position count, direction, step pulses, and optional error or illegal-transition status.
- Host-facing controls may reset position, latch count, or configure decode rate and filtering.

## Parameters and Configuration Knobs

- COUNT_WIDTH sets position range.
- DECODE_MODE selects x1, x2, or x4 edge counting.
- INDEX_EN supports an additional reference pulse.
- FILTER_EN adds digital input qualification.
- VELOCITY_HOOK_EN exposes pulses or timing suitable for downstream speed estimation.

## Internal Architecture and Dataflow

The module usually synchronizes the phase inputs, tracks their state transitions, and updates position based on legal quadrature progression. The essential contract detail is how illegal or noisy transitions are treated and whether the count saturates, wraps, or clamps.

## Clocking, Reset, and Timing Assumptions

Encoder inputs may be asynchronous and noisy. Reset should define the initial phase state and position count. If an index pulse exists, the module should state whether it is purely reported or can re-home the counter automatically.

## Latency, Throughput, and Resource Considerations

Event rates can be high for fast encoders, so input synchronization and edge handling must sustain worst-case toggle rates. Hardware cost is usually small and scales mostly with filtering and position-width options.

## Verification Strategy

- Exercise forward and reverse motion in every supported decode mode.
- Inject illegal transitions and input glitches.
- Verify index-pulse handling if supported.
- Compare position and direction outputs against a phase-transition reference model.

## Integration Notes and Dependencies

quadrature_decoder commonly pairs with pulse_capture, timers, and motor-control or servo logic. It should define clearly whether it is only a position primitive or also a source of motion-rate information.

## Edge Cases, Failure Modes, and Design Risks

- Illegal-transition policy matters because real encoders and wiring are noisy.
- Asynchronous input treatment is easy to underestimate.
- Index pulse handling can create off-by-one homing errors if not specified precisely.

## Related Modules In This Domain

- pulse_capture
- pwm_generator
- timer_block
- hall_sensor_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Quadrature Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
