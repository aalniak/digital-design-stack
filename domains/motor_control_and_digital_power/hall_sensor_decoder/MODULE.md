# Hall Sensor Decoder

## Overview

Hall Sensor Decoder interprets three Hall sensor inputs into rotor sector, direction, and coarse speed or transition timing information. It provides a low-complexity electrical position source for commutation and supervisory control.

## Domain Context

Hall decoding is the simplest rotor-position feedback path in many BLDC and entry-level PMSM drives. It converts coarse digital Hall states into commutation sector and rough speed information for control and startup sequencing.

## Problem Solved

Raw Hall inputs are asynchronous, noisy, and only loosely informative until decoded against the motor electrical sequence. A dedicated decoder is needed so position transitions, illegal states, and speed timing are handled consistently.

## Typical Use Cases

- Providing commutation sector information for trapezoidal or hybrid control.
- Supplying coarse speed feedback during startup before observer lock.
- Detecting direction of rotation and illegal Hall transitions.
- Monitoring Hall health in cost-sensitive motor drives.

## Interfaces and Signal-Level Behavior

- Inputs are raw Hall lines, optional debounce controls, and reset or enable signals.
- Outputs provide sector code, direction, transition strobe, and derived speed period or timeout flags.
- Control registers configure polarity, debounce depth, timeout thresholds, and legal sequence tables.
- Diagnostic outputs may expose illegal_state, missing_transition, and raw-versus-filtered Hall status.

## Parameters and Configuration Knobs

- Debounce time and input synchronizer depth.
- Supported Hall polarity map and sector ordering.
- Speed-period counter width and timeout range.
- Optional interpolation support between Hall edges.

## Internal Architecture and Dataflow

The decoder usually includes input synchronization, debounce or glitch filtering, legal-state decode, transition timing capture, and direction logic. The contract should document the mapping from Hall states to electrical sector explicitly because motor wiring differences make this mapping easy to misconfigure.

## Clocking, Reset, and Timing Assumptions

Hall inputs are asynchronous to the control clock and must be synchronized safely. Reset clears transition history and speed counters. If interpolation between Hall edges is used, the assumptions about constant speed between transitions should be stated honestly.

## Latency, Throughput, and Resource Considerations

Logic cost is low. Latency through synchronization and debounce must be predictable enough for commutation use. Speed resolution is limited by Hall granularity, so the block should present that limitation clearly rather than implying encoder-like precision.

## Verification Strategy

- Replay legal Hall sequences in both directions and confirm sector decode and direction.
- Inject illegal states, chatter, and missing transitions to verify diagnostics.
- Check speed-period measurement across a wide range of edge timing.
- Validate polarity and phase-order configuration for representative motor wiring variants.

## Integration Notes and Dependencies

Hall Sensor Decoder can feed Speed Loop Controller, startup logic, or hybrid observers. It should integrate with Soft Start Controller and protection logic because Hall validity often determines whether closed-loop commutation is allowed.

## Edge Cases, Failure Modes, and Design Risks

- A wrong Hall-state mapping can produce reversed or unstable commutation.
- Overaggressive debounce may delay valid edges enough to hurt commutation timing.
- If coarse Hall speed is treated like precise feedback, the speed loop can be tuned unrealistically aggressively.

## Related Modules In This Domain

- speed_observer
- soft_start_controller
- foc_current_loop
- quadrature_encoder_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Hall Sensor Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
