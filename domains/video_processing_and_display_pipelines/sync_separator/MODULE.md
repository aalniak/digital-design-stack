# Sync Separator

## Overview

The sync separator extracts usable horizontal, vertical, or field timing from a composite or embedded sync-like input so later logic can reason about frame structure. It is an ingress timing-recovery helper for certain legacy or wrapped video paths.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Some sources do not present clean discrete sync signals to the rest of the pipeline, which makes ingestion and measurement awkward. A sync separator isolates the timing structure into explicit signals that other blocks can use.

## Typical Use Cases

- Recovering line and frame timing from composite or embedded sync sources.
- Deriving usable timing signals from legacy video inputs.
- Providing reusable timing extraction in ingress wrappers.

## Interfaces and Signal-Level Behavior

- Input side accepts the composite or timing-embedded signal to analyze.
- Output side emits separated sync indications, blanking hints, or field status.
- Control side configures polarity expectations, thresholding, and timing-filter behavior.

## Parameters and Configuration Knobs

- Input width or signal format, threshold settings, and debounce or qualification timing.
- Polarity assumptions, field-detection support, and output pulse shaping.
- Runtime configuration of timing windows or filter lengths.

## Internal Architecture and Dataflow

The block monitors the incoming signal, identifies transitions or levels corresponding to sync structure, and emits normalized timing pulses for downstream use. Depending on the source, it may need filtering, pulse-width qualification, or simple state-machine decoding. The contract should state what classes of input it supports and what timing precision the outputs guarantee.

## Clocking, Reset, and Timing Assumptions

The source format and polarity must be known or selected correctly; otherwise the extracted timing may be systematically wrong. Reset should clear any internal qualification or field-detection state.

## Latency, Throughput, and Resource Considerations

This is light control-rate or line-rate logic, with cost dominated by qualification filters and counters rather than arithmetic. Reliability matters more than throughput.

## Verification Strategy

- Check extracted sync timing against known composite or embedded-sync waveforms.
- Verify polarity, debounce, and field-detection behavior.
- Confirm reset and signal-loss handling produce explicit invalid timing rather than stale outputs.

## Integration Notes and Dependencies

Sync separators typically sit at ingress boundaries and should be documented together with the source format assumptions they depend on. Integrators should also note whether downstream modules may trust extracted timing immediately or only after a stable-lock interval.

## Edge Cases, Failure Modes, and Design Risks

- A polarity or threshold mismatch can generate plausible but wrong sync pulses.
- Qualification windows that are too short or too long may fail only on certain content or noise conditions.
- If signal-loss behavior is unclear, downstream blocks may continue using stale frame timing.

## Related Modules In This Domain

- sync_generator
- deinterlacer
- hdmi_rx_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Sync Separator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
