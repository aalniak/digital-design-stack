# Timestamp Aligner

## Overview

The timestamp aligner reconciles data samples or events with a shared timing reference so multi-source systems can compare observations in one common time frame. It is the bookkeeping block that turns many local timings into one coherent chronology.

## Domain Context

Sensor acquisition and instrumentation modules connect real-world events, sampled waveforms, and measurement workflows to the digital fabric. In this domain the most important documentation topics are timing ownership, timestamp semantics, calibration assumptions, trigger behavior, and how sampled data is packed or qualified before later processing.

## Problem Solved

Different sensors and capture paths often add their own latency, buffering, and local timing markers. Without an explicit alignment stage, cross-sensor fusion and event correlation become ambiguous. This module provides that common-timeline alignment function.

## Typical Use Cases

- Aligning samples from several sensors to a shared clock or epoch.
- Correcting fixed or measured latency offsets before logging or fusion.
- Providing a reusable timing-normalization stage in instrumentation and sensor hubs.

## Interfaces and Signal-Level Behavior

- Input side accepts samples or events with associated local timestamps or timing markers.
- Output side emits aligned timestamps or data records in the chosen common time base.
- Control side configures fixed offsets, latency compensation values, and alignment mode or source selection.

## Parameters and Configuration Knobs

- Timestamp width, offset precision, buffering depth, and number of sources.
- Static versus runtime-programmable latency compensation and epoch-adjust policy.
- Metadata pass-through behavior and output ordering rules.

## Internal Architecture and Dataflow

The aligner typically adds or subtracts configured delay compensation, buffers data until timing order can be resolved, and then emits records tagged in the common time frame. More advanced versions may compensate source-specific transport delay or support epoch changes. The contract should specify whether alignment preserves arrival order or strict timestamp order when those differ.

## Clocking, Reset, and Timing Assumptions

Alignment only works if all timestamps share a meaningful relation to a reference epoch, so source-timing assumptions belong in the documentation. Reset should clear buffered records and reestablish the selected epoch cleanly.

## Latency, Throughput, and Resource Considerations

This block is not arithmetic heavy, but buffering and ordering policy can affect latency and memory use. Throughput depends on source count and how much reordering is permitted.

## Verification Strategy

- Check fixed-offset and mixed-latency cases against a timing reference model.
- Verify ordering policy under out-of-order arrivals or close timestamps.
- Confirm epoch changes and reset behavior do not leak stale buffered records.

## Integration Notes and Dependencies

Timestamp aligners are central to multi-sensor systems, so the ownership of the common epoch and latency numbers should be documented with them. Integrators should also specify whether downstream consumers may assume aligned outputs are monotonic in time.

## Edge Cases, Failure Modes, and Design Risks

- Wrong latency compensation values can make independently correct sensors disagree systematically.
- If arrival order and timestamp order are not distinguished, downstream correlation may become inconsistent.
- Epoch transitions are easy to mishandle and can invalidate large chunks of data silently.

## Related Modules In This Domain

- time_to_digital_capture
- sensor_hub_mux
- sample_packer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Timestamp Aligner module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
