# Deinterlacer

## Overview

The deinterlacer converts interlaced video fields into progressive frames suitable for modern display and analysis pipelines. It is a temporal and spatial reconstruction stage rather than a simple format relabeling step.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Interlaced video carries alternating fields rather than full progressive frames, and treating those fields as if they were progressive creates combing artifacts and temporal instability. This module reconstructs a progressive representation with an explicit deinterlacing strategy.

## Typical Use Cases

- Preparing legacy interlaced sources for progressive displays or encoders.
- Cleaning broadcast or video-capture inputs before analytics.
- Providing a reusable progressive-conversion stage in mixed-format video systems.

## Interfaces and Signal-Level Behavior

- Input side accepts interlaced fields with field ID, line timing, and pixel data.
- Output side emits progressive raster frames with documented cadence and latency.
- Control side selects deinterlacing mode, field-order convention, and motion or interpolation policy.

## Parameters and Configuration Knobs

- Pixel width, line-buffer or frame-buffer depth, field order, and deinterlace algorithm mode.
- Temporal versus spatial interpolation policy, output cadence, and border handling.
- Runtime mode selection and reset behavior across field boundaries.

## Internal Architecture and Dataflow

The block uses one or more fields to reconstruct missing lines for each output frame. Simple versions bob or weave fields, while richer versions use motion-adaptive interpolation. The documentation should state exactly what algorithm class is implemented and whether latency includes one or more field stores.

## Clocking, Reset, and Timing Assumptions

Field order, timing, and cadence must be known accurately; otherwise even a correct algorithm will reconstruct the wrong temporal sequence. Reset should define how the first few output frames are generated when not enough field history exists yet.

## Latency, Throughput, and Resource Considerations

Deinterlacing often requires significant line or frame buffering and may include nontrivial interpolation logic. Resource cost depends heavily on algorithm sophistication and supported resolutions.

## Verification Strategy

- Compare output against a software or golden-reference deinterlacer on known field sequences.
- Check field-order handling, startup behavior, and motion-adaptive mode transitions if supported.
- Verify that cadence and output timing match the documented progressive format.

## Integration Notes and Dependencies

This block usually sits near ingress from legacy sources and before modern display or analytics stages. Integrators should document the chosen field-order and temporal-latency contract because those affect lip-sync and motion interpretation.

## Edge Cases, Failure Modes, and Design Risks

- A field-order mismatch creates persistent motion judder that can be hard to localize in a large pipeline.
- Simple weave or bob assumptions may be unacceptable for the intended content even if the hardware is correct.
- Startup and field-loss behavior can create intermittent artifacts if not defined explicitly.

## Related Modules In This Domain

- frame_rate_converter
- video_scaler
- sync_separator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Deinterlacer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
