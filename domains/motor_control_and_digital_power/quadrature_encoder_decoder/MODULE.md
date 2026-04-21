# Quadrature Encoder Decoder

## Overview

Quadrature Encoder Decoder converts incremental encoder signals into position count, direction, index-aligned state, and derived speed or period measurements. It provides high-resolution shaft feedback for closed-loop motion control.

## Domain Context

Quadrature encoder decoding is the standard digital interface for incremental shaft position feedback in many motion-control systems. It translates A and B phase edges, and often index pulses, into precise count, direction, and speed information for servo control.

## Problem Solved

Raw A/B edges are asynchronous and can include bounce, skew, or phase errors. A dedicated decoder ensures legal count transitions, index handling, and position rollover are implemented consistently and safely.

## Typical Use Cases

- Providing rotor or shaft position feedback for servo drives.
- Deriving high-resolution speed measurements from incremental encoder transitions.
- Aligning absolute mechanical zero using the index pulse.
- Detecting encoder wiring faults or illegal phase transitions.

## Interfaces and Signal-Level Behavior

- Inputs are encoder A, B, optional Z index, and enable or reset signals.
- Outputs provide position count, direction, index_seen state, and optional speed-period data.
- Control registers configure x1 x2 x4 decode mode, polarity, rollover limits, and index reset policy.
- Diagnostic outputs may expose illegal_transition, missing_index, and input filter status.

## Parameters and Configuration Knobs

- Counter width and rollover behavior.
- Decode mode and input filter depth.
- Index handling policy and optional homing latch support.
- Speed measurement counter width and update cadence.

## Internal Architecture and Dataflow

A typical implementation contains synchronized inputs, transition-state decode, count update logic, optional index processing, and speed estimation support. The contract should define whether the count updates before or after index handling and how illegal transitions affect position continuity.

## Clocking, Reset, and Timing Assumptions

Encoder inputs are asynchronous and must be synchronized to the control domain. Reset sets count and index state to documented values. If mechanical backlash or bounce filtering is expected to be handled elsewhere, that division of responsibility should be stated.

## Latency, Throughput, and Resource Considerations

Logic cost is low to moderate. Accurate operation at high edge rates is the main challenge, especially with x4 decoding. Latency is usually small, but deterministic count semantics are critical for servo positioning.

## Verification Strategy

- Replay valid quadrature sequences at multiple speeds and decode modes.
- Inject illegal transitions, swapped channels, and missing index pulses.
- Verify count direction, rollover, and index reset behavior.
- Check speed-estimation output against synthetic edge timing references.

## Integration Notes and Dependencies

Quadrature Encoder Decoder feeds Speed Observer, motion loops, and homing logic. It should align with mechanical zero conventions and with any resolver or Hall fallback path used by the system.

## Edge Cases, Failure Modes, and Design Risks

- A channel swap or sign convention mistake can invert position and destabilize control.
- Illegal-transition handling that silently counts anyway can create hard-to-debug position drift.
- If index reset semantics are unclear, homing procedures may not be repeatable.

## Related Modules In This Domain

- speed_observer
- speed_loop_controller
- resolver_interface
- soft_start_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Quadrature Encoder Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
