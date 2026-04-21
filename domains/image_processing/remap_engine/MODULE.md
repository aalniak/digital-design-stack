# Remap Engine

## Overview

The remap engine applies an arbitrary per-pixel coordinate mapping from destination space back to source space, supporting lens distortion correction, perspective correction, and calibration-driven geometric compensation beyond simple affine transforms. It is a general geometric image-warp primitive.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Many practical camera and vision pipelines need coordinate transforms that are not affine, such as lens undistortion or calibration maps. A general remap stage handles those cases, but it requires a precise coordinate-map contract and careful memory behavior. This module provides that reusable remapping capability.

## Typical Use Cases

- Applying lens-distortion correction based on calibration maps.
- Performing per-pixel geometric correction before vision algorithms.
- Supporting calibrated spatial remaps that do not fit a small closed-form transform.

## Interfaces and Signal-Level Behavior

- Input side accepts source image data through a frame buffer or random-access pixel source.
- Output side emits remapped pixels on the destination raster grid.
- Control side provides coordinate maps, interpolation mode, border policy, and destination geometry.

## Parameters and Configuration Knobs

- Coordinate-map precision, interpolation mode, pixel width, and source or destination dimensions.
- Map memory format, border fill behavior, and runtime map-bank switching.
- Support for fixed-point coordinate maps, nearest-neighbor or bilinear interpolation, and optional validity masks.

## Internal Architecture and Dataflow

For each destination coordinate, the block reads a mapped source coordinate from a calibration map, fetches the required source pixels, and interpolates according to the configured mode. The complexity lies in coordinate storage, memory bandwidth, and strict interpretation of the map convention. The documentation should state whether the map stores source coordinates directly, offsets, or normalized values.

## Clocking, Reset, and Timing Assumptions

The coordinate map is meaningful only with the documented image origin, pixel-center convention, and lens calibration state. Reset and map updates should not create mixed-map frames unless that is an explicit operating mode.

## Latency, Throughput, and Resource Considerations

Remap engines are often memory-bandwidth limited because source access is nonraster and map lookup is required for every destination pixel. Arithmetic cost is secondary to data movement and interpolation.

## Verification Strategy

- Compare remapped output against a software reference using calibration maps and synthetic grids.
- Check map interpretation, border fill, and interpolation mode.
- Verify map-bank switching and reset behavior at frame boundaries.

## Integration Notes and Dependencies

This block usually sits where frame-buffer access is available and where geometric correctness matters more than minimum latency. Integrators should document the calibration source for the map and the intended destination geometry.

## Edge Cases, Failure Modes, and Design Risks

- A map convention mismatch can produce believable but wrong geometry across the full image.
- Interpolation differences from calibration software can shift edges or keypoints enough to affect later stages.
- Bandwidth shortfalls can create subtle dropped-pixel or stall behavior if not designed explicitly.

## Related Modules In This Domain

- affine_warp
- crop_resize_rotate
- lens_shading_correction

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Remap Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
