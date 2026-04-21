# Pulse Counter

## Overview

The pulse counter counts discrete pulse events and often qualifies or latches the count over a defined observation window. It is a simple instrumentation primitive for rate, activity, and event-total measurements.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Counting pulses should be easy, but asynchronous edges, gating windows, rollover policy, and count readout timing matter when the result is used for control or logging. This module gives that apparently simple function a clear, reusable contract.

## Typical Use Cases

- Counting trigger events, tachometer pulses, or detector hits.
- Providing event totals over a measurement interval or runtime period.
- Supporting embedded instrumentation and activity monitoring.

## Interfaces and Signal-Level Behavior

- Input side accepts the event or pulse stream to be counted.
- Control side supplies gate, clear, latch, or read-trigger behavior as needed.
- Output side emits the live count or latched count plus overflow or validity status.

## Parameters and Configuration Knobs

- Counter width, edge sensitivity, asynchronous capture policy, and gate behavior.
- Auto-clear versus running-total mode and overflow or saturation policy.
- Optional debounce or qualification support.

## Internal Architecture and Dataflow

The core increments a counter on each qualified event edge and may optionally latch the result on a gate boundary or read command. More robust versions include synchronizers, edge detectors, and debounce or qualification logic when the pulse source is noisy. Documentation should state whether the output is instantaneous, windowed, or cumulative.

## Clocking, Reset, and Timing Assumptions

The physical meaning of the count depends on the observation interval and edge-definition convention. Reset should initialize all counters and any latch state deterministically.

## Latency, Throughput, and Resource Considerations

Pulse counting is cheap in area, but the asynchronous input path and counter width still deserve care. Maximum measurable rate depends on edge-capture design and clocking assumptions.

## Verification Strategy

- Check counts against known pulse patterns, including back-to-back edges and boundary timing cases.
- Verify overflow, gating, and clear behavior.
- Confirm debouncing or qualification logic when enabled.

## Integration Notes and Dependencies

This block is often paired with frequency counters, timestamp units, or trigger logic. Integrators should document whether counts are raw totals or normalized later in software or adjacent logic.

## Edge Cases, Failure Modes, and Design Risks

- Missed or double-counted asynchronous edges can remain hidden until high-rate operation.
- A vague definition of what resets or latches the counter makes measurements hard to compare.
- If counts wrap silently, long-duration logging can become misleading.

## Related Modules In This Domain

- frequency_counter
- event_detector
- trigger_sequencer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pulse Counter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
