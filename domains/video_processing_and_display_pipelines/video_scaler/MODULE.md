# Video Scaler

## Overview

The video scaler resizes raster images between source and destination resolutions using a documented interpolation policy while preserving overall frame structure. It is one of the most common stages in video display and adaptation pipelines.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Display and processing systems frequently need the same content at several resolutions, but simple pixel replication or dropping is often not acceptable. A scaler provides the necessary geometric resampling with explicit timing and quality tradeoffs. This module packages that adaptation stage.

## Typical Use Cases

- Matching input video to display panel resolution.
- Generating resized streams for preview, analytics, or recording.
- Providing reusable resolution adaptation in video pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts a source raster stream or frame-buffer-backed source.
- Output side emits the destination raster stream with preserved frame cadence and documented latency.
- Control side configures source and destination geometry, interpolation mode, and border policy.

## Parameters and Configuration Knobs

- Source and destination dimensions, pixel width, interpolation mode, and coordinate precision.
- Horizontal and vertical scaling ratios, buffer depth, and optional sharpen or phase controls.
- Frame-synchronous runtime update policy and support for upscaling versus downscaling modes.

## Internal Architecture and Dataflow

The scaler maps destination coordinates to source positions and reconstructs output pixels using nearest-neighbor, bilinear, or another supported interpolation method. Streaming scalers often buffer lines and use phase accumulators to manage resampling. The contract should define the coordinate convention and whether scaling latency is line based, frame based, or purely pipelined.

## Clocking, Reset, and Timing Assumptions

Source timing and geometry must match the configured input size, and the interpolation mode must be interpreted relative to a documented pixel-center convention. Reset should clear phase and line-buffer state before a new frame starts.

## Latency, Throughput, and Resource Considerations

Scaling is moderate in cost and often bandwidth limited for larger kernels or memory-backed implementations. Resource use depends on interpolation quality, line buffering, and ratio precision.

## Verification Strategy

- Compare scaled output against a software reference for upscaling and downscaling cases.
- Check coordinate convention, border policy, and runtime size changes at frame boundaries.
- Verify line-buffer and phase-state reset behavior.

## Integration Notes and Dependencies

This block often sits near display output or ROI generation paths, so its size and coordinate conventions should be documented with neighboring geometry-aware blocks. Integrators should also note whether scaling is intended for visual quality or for fast machine-vision preprocessing.

## Edge Cases, Failure Modes, and Design Risks

- A half-pixel coordinate mismatch can create persistent geometry offsets relative to software references.
- Interpolation differences can affect both perceived sharpness and ML inference behavior.
- Unsafe size changes can create partial-frame artifacts or output timing discontinuities.

## Related Modules In This Domain

- crop_resize_rotate
- frame_rate_converter
- video_timing_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Video Scaler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
