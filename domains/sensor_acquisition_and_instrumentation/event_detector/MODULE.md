# Event Detector

## Overview

The event detector identifies occurrences of interest in a sample or status stream and raises structured indications that later logic can count, timestamp, or trigger from. It is the generic bridge from continuous observation to discrete measurement events.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Many systems care only about specific crossings, patterns, or condition changes rather than every raw sample. Ad hoc event logic tends to scatter thresholds, holdoff rules, and flag semantics throughout the design. This module centralizes that detection boundary.

## Typical Use Cases

- Detecting threshold crossings, state transitions, or signal signatures in acquisition data.
- Generating measurement events for counters, timestamp units, or trigger sequencers.
- Providing a reusable event abstraction for instrumentation workflows.

## Interfaces and Signal-Level Behavior

- Input side accepts a sample stream or status stream plus optional qualifier signals.
- Output side emits event pulses, event metadata, and optional latched status.
- Control side configures detection criteria, holdoff intervals, and event enable or mask behavior.

## Parameters and Configuration Knobs

- Input width, comparison or pattern logic mode, and event pulse policy.
- Holdoff or debounce interval, qualifier support, and metadata width.
- Runtime programmability for thresholds or pattern templates.

## Internal Architecture and Dataflow

The block monitors incoming values or state and applies configured criteria to determine when an event should be emitted. It may include edge detection, pattern qualification, and holdoff logic to prevent repeated firing on the same physical phenomenon. The contract should define exactly what constitutes one event and how simultaneous or overlapping conditions are resolved.

## Clocking, Reset, and Timing Assumptions

The detector only makes sense in the units and sample cadence of the incoming data stream, so those assumptions should remain visible. Reset should clear any holdoff or latched-event state cleanly.

## Latency, Throughput, and Resource Considerations

Event detection is usually lightweight and can run at full sample rate if necessary. Resource use depends on pattern complexity and buffering for qualification history.

## Verification Strategy

- Check event timing and pulse semantics against known sample sequences and edge cases.
- Verify holdoff and qualifier behavior under repeated near-threshold conditions.
- Confirm reset and enable transitions do not create false events.

## Integration Notes and Dependencies

Event detectors often feed timestamp, trigger, and counting blocks, so their event definition should be documented centrally. Integrators should also note whether event pulses are one cycle long or stretched for slower domains.

## Edge Cases, Failure Modes, and Design Risks

- Ambiguous event definitions can make counters and timestamps disagree about what was observed.
- Holdoff that is too aggressive can hide real repeated events.
- If thresholds or patterns change midstream without coordination, the detector may fire unpredictably.

## Related Modules In This Domain

- threshold_detector
- trigger_sequencer
- timestamp_aligner

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Event Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
