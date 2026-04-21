# Video Mixer

## Overview

The video mixer selects, crossfades, or otherwise combines several full video inputs into one output stream according to configured routing policy. It sits above primitive blending and below full scene compositors in many systems.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Many systems need to switch or merge among several complete video sources, but simple muxing can cause timing discontinuities or abrupt scene changes. This module provides a structured mixer that keeps raster contracts explicit while managing source selection and optional transitions.

## Typical Use Cases

- Switching between several camera or playback sources.
- Crossfading or mixing full-frame video channels.
- Providing reusable source-selection logic in broadcast or embedded display systems.

## Interfaces and Signal-Level Behavior

- Input side accepts several complete video streams with timing and format metadata.
- Output side emits the selected or mixed video stream and optional transition status.
- Control side configures source selection, transition mode, blend amount, and safe-switch boundaries.

## Parameters and Configuration Knobs

- Number of inputs, pixel format, transition support, and buffering depth.
- Cut versus blend modes, frame-synchronous switching policy, and timing-alignment behavior.
- Optional per-input color conversion or format normalization if included.

## Internal Architecture and Dataflow

The mixer time-aligns or otherwise coordinates the candidate video streams, chooses which input contributes to each output pixel or frame, and optionally blends between sources during transitions. The documentation should state whether switches happen on frame boundaries only, whether crossfades are supported, and what assumptions are made about matching input formats and timing.

## Clocking, Reset, and Timing Assumptions

Inputs must either share a common timing domain or be normalized before mixing, and that requirement should be explicit. Reset should select a known default source or blank output state.

## Latency, Throughput, and Resource Considerations

Mixing full video streams is moderately expensive due to buffering and possible blending, but still usually lighter than arbitrary compositing. Resource use grows with input count and transition features.

## Verification Strategy

- Check source selection, crossfade behavior, and frame-boundary switching policy against a scene reference.
- Verify output timing when inputs are delayed, disabled, or mismatched.
- Confirm reset and source-loss behavior are explicit and deterministic.

## Integration Notes and Dependencies

This block often sits between source wrappers and final display stages, so supported input-format assumptions should be documented. Integrators should also state whether switching latency is frame synchronous or immediate.

## Edge Cases, Failure Modes, and Design Risks

- Switching between unsynchronized streams can create tearing or unstable output.
- If default-source behavior is unclear, reset or source-loss handling becomes ambiguous.
- Crossfade arithmetic mismatches can shift brightness or color during transitions.

## Related Modules In This Domain

- compositor
- alpha_blender
- frame_buffer_reader

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Video Mixer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
