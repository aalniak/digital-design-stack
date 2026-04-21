# Alpha Blender

## Overview

The alpha blender combines foreground and background pixel streams using an alpha or coverage term to produce translucent overlays and layered video output. It is a core compositing primitive for graphics, OSD, and UI-style video paths.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Layered video systems need more than hard pixel replacement; they need controlled blending that preserves timing, color format, and numeric range. This module provides that blend operation explicitly so overlays and graphics can be integrated predictably.

## Typical Use Cases

- Blending an on-screen display over a live video stream.
- Combining camera and graphics layers with transparency.
- Providing a reusable translucent composition stage in video pipelines.

## Interfaces and Signal-Level Behavior

- Foreground and background inputs accept synchronized pixel streams with matching raster timing or a documented alignment policy.
- Output side emits the blended pixel stream in the chosen color format.
- Control side supplies constant or per-pixel alpha, pre-multiplied mode selection, and clamp behavior.

## Parameters and Configuration Knobs

- Pixel width, channel count, alpha precision, and color format.
- Straight-alpha versus premultiplied-alpha mode, rounding, and clamp policy.
- Optional per-pixel alpha sideband support and timing-alignment buffering.

## Internal Architecture and Dataflow

The block computes a weighted combination of foreground and background channels according to the configured alpha interpretation, often using per-channel multiply-add arithmetic and optional premultiplication assumptions. The documentation should state whether alpha is normalized over the full numeric range, how it is applied at channel boundaries, and whether streams must already be time aligned.

## Clocking, Reset, and Timing Assumptions

The meaning of alpha depends on the color format and on whether the source pixels are straight or premultiplied, so those assumptions must be visible. Reset should clear any internal alignment buffers so the first blended frame starts on a clean raster boundary.

## Latency, Throughput, and Resource Considerations

Blending is moderate-cost per pixel and can usually sustain video rate with pipelined multipliers. Resource use depends on channel count, alpha precision, and buffering for stream alignment.

## Verification Strategy

- Compare output against a reference alpha blend for several alpha values and color ranges.
- Check premultiplied and straight-alpha behavior if both are supported.
- Verify raster alignment and frame-boundary reset behavior.

## Integration Notes and Dependencies

This block often sits near compositors, OSD engines, and video mixers, so the color-range and alpha semantics should be documented consistently across those neighbors. Integrators should also note whether graphics timing is locked to the base video stream or independently buffered.

## Edge Cases, Failure Modes, and Design Risks

- A premultiplied-versus-straight alpha mismatch produces plausible but wrong visual results.
- If the two input streams are even one pixel out of alignment, overlay placement becomes visibly incorrect.
- Clamp policy differences can shift color near saturation and be hard to trace later.

## Related Modules In This Domain

- compositor
- osd_engine
- video_mixer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Alpha Blender module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
