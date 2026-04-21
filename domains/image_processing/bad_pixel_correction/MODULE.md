# Bad Pixel Correction

## Overview

The bad pixel correction module detects or replaces known defective sensor pixels using neighboring image context or a defect map. It is an early pipeline-cleanup stage that prevents isolated sensor defects from contaminating later image processing.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Real sensors contain hot, dead, or unstable pixels that create isolated image artifacts and can confuse downstream demosaicing and statistics. This module corrects those defects in a structured, documented way before later stages amplify or misinterpret them.

## Typical Use Cases

- Cleaning raw sensor streams before demosaicing or color processing.
- Applying factory-provided defect maps in camera pipelines.
- Reducing the impact of isolated pixel defects on machine-vision algorithms and image-quality metrics.

## Interfaces and Signal-Level Behavior

- Input side accepts raw or grayscale pixel streams with frame and line markers.
- Output side emits corrected pixels in the same format and timing domain.
- Control side loads defect maps, detection thresholds, and replacement mode such as interpolation from neighbors.

## Parameters and Configuration Knobs

- Pixel width, defect-map depth, neighborhood shape, and replacement policy.
- Static defect-map mode versus dynamic outlier detection enable.
- Border handling and optional per-color-plane awareness for Bayer data.

## Internal Architecture and Dataflow

The module either consults a known defect map or compares a pixel against its neighborhood to decide whether the value is implausible. If correction is needed, it replaces the pixel using an interpolation rule based on nearby samples, often respecting the sensor color pattern. Documentation should state whether detection is static, dynamic, or both, and when corrected pixels are marked or left indistinguishable from ordinary output.

## Clocking, Reset, and Timing Assumptions

The module should know whether the input is raw Bayer or another format, because valid replacement neighbors depend on that context. Reset must clear neighborhood state so line and frame boundaries do not contaminate correction decisions.

## Latency, Throughput, and Resource Considerations

Bad pixel correction is an early local-neighborhood operation and can often run at one pixel per cycle with line buffering. Resource use depends on defect-map storage and neighborhood window size.

## Verification Strategy

- Compare corrected output against a software reference using synthetic defect maps and dynamic outlier cases.
- Check color-plane awareness, border behavior, and frame resets.
- Verify that ordinary high-contrast edges are not mistaken for bad pixels too aggressively.

## Integration Notes and Dependencies

This block usually belongs before demosaicing and most ISP statistics, and that placement should be documented clearly. Integrators should also state whether corrected-pixel counts are exposed for health monitoring.

## Edge Cases, Failure Modes, and Design Risks

- Placing the block too late in the pipeline can smear defects into several color channels or neighborhoods.
- Dynamic detection that is too aggressive can erase real small features.
- Defect-map indexing errors may silently correct the wrong locations while leaving actual defects untouched.

## Related Modules In This Domain

- bayer_unpacker
- black_level_correction
- ae_awb_af_statistics

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bad Pixel Correction module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
