# Time-to-Digital Capture

## Overview

The time-to-digital capture module measures event timing with finer resolution than the base fabric clock by combining coarse and fine timing information. It is a core primitive for ranging, synchronization, and high-resolution timing instruments.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Many applications need to know when an event occurred more precisely than a system clock period allows. A TDC-style capture module provides that precision, but only if coarse counters, fine interpolators, and calibration are handled rigorously. This module packages that measurement path for reuse.

## Typical Use Cases

- Measuring time of flight, pulse arrival, or edge alignment with sub-clock precision.
- Providing fine timestamping for timing and synchronization instruments.
- Supporting high-resolution edge timing in research and sensing platforms.

## Interfaces and Signal-Level Behavior

- Event side accepts one or more edge or pulse inputs to be timed.
- Reference side provides the coarse clock and any fine-delay or interpolation calibration information.
- Output side emits coarse and fine timestamps, validity flags, and optional overflow or ambiguity status.

## Parameters and Configuration Knobs

- Coarse counter width, fine-resolution format, channel count, and edge polarity support.
- Calibration hooks, buffering depth, and whether multi-hit capture is supported.
- Output packing style and timestamp epoch behavior.

## Internal Architecture and Dataflow

A TDC capture path usually records a coarse time from a running counter and a fine time from a calibrated delay or interpolation structure, then combines them into one timestamp result. Some implementations support multiple rapid hits or channelized capture. The documentation should state whether fine values are raw codes, calibrated units, or intermediate values that require later conversion.

## Clocking, Reset, and Timing Assumptions

Fine timing accuracy depends on calibration and environmental stability, so those dependencies should be explicit. Reset must define the timestamp epoch and clear any stale event records or interpolation state.

## Latency, Throughput, and Resource Considerations

The logic cost is modest, but precision is determined by analog-like delay structure and calibration quality rather than just digital width. Throughput depends on whether multiple closely spaced events can be buffered.

## Verification Strategy

- Compare measured timestamps against known synthetic edge timing patterns and calibration models.
- Verify overflow, simultaneous-event, and multi-hit behavior if supported.
- Check reset and epoch handling so coarse and fine fields remain consistent.

## Integration Notes and Dependencies

TDC capture often feeds histogram, ranging, or synchronization blocks, so the meaning of the fine field must be documented centrally. Integrators should also state whether timestamps are already temperature compensated or need later correction.

## Edge Cases, Failure Modes, and Design Risks

- Uncalibrated fine timing can look precise while still being inaccurate.
- Coarse and fine fields that are captured inconsistently near a clock boundary can create one-cycle ambiguity.
- If multi-hit behavior is not explicit, closely spaced events may be dropped silently.

## Related Modules In This Domain

- frequency_counter
- timestamp_aligner
- histogram_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Time-to-Digital Capture module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
