# OSD Engine

## Overview

The OSD engine renders or inserts text, icons, cursors, and simple graphics into a video stream according to configured positions and styles. It is a specialized overlay generator for user-facing video systems.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Many display systems need annotations, menus, or status graphics, but full graphics stacks are excessive for simple embedded overlays. This module provides the focused raster-graphics features needed for an on-screen display while keeping timing and blending explicit.

## Typical Use Cases

- Adding text labels, cursors, and status banners to live video.
- Providing lightweight UI overlays in embedded displays and instruments.
- Serving as a reusable annotation stage ahead of final compositing.

## Interfaces and Signal-Level Behavior

- Base-video input accepts a raster stream or background layer.
- Overlay side consumes glyph, bitmap, or primitive control data and outputs composed pixels or an overlay plane.
- Control side configures positions, colors, fonts, alpha, and enable masks.

## Parameters and Configuration Knobs

- Pixel format, overlay plane count, glyph or bitmap storage organization, and alpha support.
- Coordinate precision, font dimensions, and optional animation or cursor modes.
- Runtime update policy for overlay contents and positions.

## Internal Architecture and Dataflow

The engine determines for each pixel whether an OSD element covers the current coordinate, fetches any required glyph or bitmap data, and then selects or blends the overlay color into the output stream. Some designs output a separate overlay plane, while others directly composite onto the base video. The contract should state which model is used and how overlay memory updates are synchronized.

## Clocking, Reset, and Timing Assumptions

OSD coordinates and color format must be interpreted in the same raster and pixel domain as the base video. Reset should clear any pending overlay state so the first output frame does not contain stale UI artifacts.

## Latency, Throughput, and Resource Considerations

OSD engines are moderate in cost, with resource use shaped by glyph memory, coordinate tests, and optional alpha blending. Throughput must match the base video pixel rate.

## Verification Strategy

- Compare rendered overlay placement and appearance against a software raster reference.
- Check font or bitmap addressing, alpha behavior, and frame-boundary update synchronization.
- Verify that disabled or transparent regions leave the base video unchanged.

## Integration Notes and Dependencies

This block often works closely with alpha blenders and compositors, so layer and alpha conventions should be documented consistently. Integrators should also note whether text and graphics content can update asynchronously or only on frame boundaries.

## Edge Cases, Failure Modes, and Design Risks

- Coordinate or glyph-address mistakes can create overlays that are only slightly misplaced and difficult to debug.
- Asynchronous content updates can produce tearing in visible UI elements.
- If color format assumptions differ from the base video, overlays may render with the wrong colors or transparency.

## Related Modules In This Domain

- alpha_blender
- compositor
- video_mixer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the OSD Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
