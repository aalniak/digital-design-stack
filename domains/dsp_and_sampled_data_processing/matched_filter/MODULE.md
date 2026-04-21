# Matched Filter

## Overview

The matched filter maximizes response to a known waveform in noise by correlating the input against a time-reversed or conjugated reference template. It is one of the most important detection primitives in radar, sonar, communications, and synchronization systems.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Detecting a known pulse or preamble robustly requires more than generic filtering. A matched filter is optimal under common noise assumptions, but its coefficient construction, output interpretation, and latency need to be made explicit in hardware. This module provides that focused detection filter rather than leaving each project to derive it ad hoc.

## Typical Use Cases

- Pulse compression in radar or sonar pipelines.
- Preamble detection and timing acquisition in communications receivers.
- Reference-waveform detection in laboratory instruments and sensing systems.

## Interfaces and Signal-Level Behavior

- Input side accepts real or complex sample streams.
- Reference side defines the expected waveform coefficients, often fixed or loaded before operation.
- Output side emits detection scores, filtered samples, or peak-ready metadata for downstream thresholding.

## Parameters and Configuration Knobs

- Reference length, coefficient precision, data width, and complex versus real mode.
- Normalization choice, output accumulation width, and optional decimation or block framing.
- Runtime template reload support and coefficient storage organization.

## Internal Architecture and Dataflow

In hardware the matched filter is usually implemented as an FIR whose coefficients are derived from the expected waveform, often reversed in time and conjugated for complex data. The output peak occurs at a defined lag relative to the input, so documentation must tie the peak location to the input sample index clearly. Some systems expose the full filtered waveform, while others only publish peaks or threshold events.

## Clocking, Reset, and Timing Assumptions

The template must match the expected signal shape and sample rate convention, so those design assumptions belong alongside the module. Reset and template changes should clear or define the internal history so outputs are not mixed across references.

## Latency, Throughput, and Resource Considerations

Matched filters can be resource intensive for long templates, but they are still often easier to reason about than more abstract detectors. Throughput follows FIR architecture choices, while latency is set by template length and pipelining.

## Verification Strategy

- Compare peak amplitude and lag against a reference model for several test waveforms and SNR conditions.
- Check conjugation and coefficient ordering in complex mode.
- Verify template reload and startup behavior so stale history does not create false peaks.

## Integration Notes and Dependencies

This block often feeds threshold detectors, trackers, or synchronizers, so the timing of the output peak relative to input samples must be documented precisely. Integrators should also track whether outputs are normalized or raw-energy dependent.

## Edge Cases, Failure Modes, and Design Risks

- A lag convention mistake can make the detector consistently late or early while still showing strong peaks.
- Template scaling changes can alter threshold tuning across builds.
- If complex conjugation is omitted or reversed, the response may collapse for phase-sensitive signals.

## Related Modules In This Domain

- correlator
- fir_filter
- threshold_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Matched Filter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
