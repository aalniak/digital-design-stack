# Affine Warp

## Overview

The affine warp module remaps image coordinates through a configurable affine transform, enabling translation, rotation, scaling, and shear operations on a pixel stream or frame buffer. It is a geometric image-processing primitive used in stabilization, registration, and preprocessing.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Geometric corrections and coordinate remapping are common in image pipelines, but they require careful interpolation, border policy, and coordinate precision handling. This module provides a reusable affine transform stage with those details documented explicitly.

## Typical Use Cases

- Rotating or scaling images for display or preprocessing.
- Applying geometric correction before registration, detection, or stitching.
- Serving as a reusable remap stage in camera or computer-vision pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts a source image stream or frame-buffer read interface in a documented pixel format.
- Output side emits transformed pixels on a new grid with frame and line timing appropriate to the destination image.
- Control side loads affine coefficients, output geometry, interpolation mode, and border policy.

## Parameters and Configuration Knobs

- Pixel width, coordinate precision, interpolation type, and source or destination dimensions.
- Coefficient precision, border-fill policy, and memory or line-buffer architecture.
- Support for runtime transform updates and fixed versus programmable output geometry.

## Internal Architecture and Dataflow

The module maps each destination pixel coordinate back to a source coordinate using the affine matrix, fetches the required source samples, and interpolates or selects a nearest neighbor according to configuration. Streaming implementations often need external frame buffers or tiled memory access because source pixels are not consumed in simple raster order. The contract should state the coordinate convention and whether coefficients are source-to-destination or destination-to-source.

## Clocking, Reset, and Timing Assumptions

Affine coefficients are meaningful only with a documented pixel-center convention and image origin definition. Reset and transform updates should not mix coefficient sets within a frame unless that is an explicit feature.

## Latency, Throughput, and Resource Considerations

Affine warps are moderate to expensive depending on interpolation quality and memory access pattern. Throughput is often limited more by source-pixel fetch behavior than by the arithmetic itself.

## Verification Strategy

- Compare transformed images against a software affine-warp reference for translation, rotation, and scaling cases.
- Check border policy, interpolation mode, and coefficient update boundaries.
- Verify coordinate precision and origin conventions to avoid one-pixel systematic shifts.

## Integration Notes and Dependencies

This block usually lives where frame-buffer access is available, and its placement relative to color conversion and statistics stages affects both cost and output meaning. Integrators should document output image dimensions and geometric conventions alongside the transform coefficients.

## Edge Cases, Failure Modes, and Design Risks

- A source versus destination coordinate convention mismatch can produce plausible but wrong warps.
- Interpolation and border choices that differ from the expected software path can change downstream model behavior.
- Frame-boundary violations during coefficient updates can create tearing-like artifacts.

## Related Modules In This Domain

- bayer_unpacker
- bad_pixel_correction
- adaptive_thresholding

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Affine Warp module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
