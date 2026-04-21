# Chroma Resampler

## Overview

The chroma resampler converts chroma planes or streams between sampling schemes such as 4:4:4, 4:2:2, and 4:2:0 while preserving luma timing and color-domain consistency. It is a standard video-format adaptation stage.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Video systems often need to bridge different chroma subsampling formats, but that change affects sample alignment, interpolation, and memory packing. This module centralizes those resampling rules so downstream stages can trust the declared format.

## Typical Use Cases

- Converting camera or graphics content between RGB-derived YUV formats.
- Adapting video for encoders, decoders, or display interfaces with specific chroma sampling requirements.
- Providing a reusable format bridge in mixed-format video pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts luma and chroma samples or packed YUV pixels in a documented subsampling format.
- Output side emits the target chroma-sampled format with preserved frame timing.
- Control side selects source and destination format, interpolation mode, and siting convention.

## Parameters and Configuration Knobs

- Input and output chroma formats, channel widths, and chroma siting policy.
- Interpolation or decimation mode, border policy, and packed versus planar interface style.
- Runtime mode selection and frame-synchronous update support.

## Internal Architecture and Dataflow

The block upsamples or downsamples chroma relative to luma according to the selected source and destination schemes, often with simple FIR interpolation or decimation filters. The contract should define chroma siting explicitly, because sample-center assumptions differ across standards and affect color alignment visibly.

## Clocking, Reset, and Timing Assumptions

Input and output color range and chroma siting must be known and documented, because these choices change the expected pixel values. Reset should clear line and phase state so format conversion restarts cleanly at frame boundaries.

## Latency, Throughput, and Resource Considerations

Chroma resampling is moderate in cost and often uses line buffers plus simple interpolation filters. Resource use depends on subsampling ratio and whether several formats are supported in one implementation.

## Verification Strategy

- Compare converted output against a software reference for several format pairs and chroma siting conventions.
- Check border handling, phase alignment, and frame-boundary resets.
- Verify packed and planar data-path behavior if both are supported.

## Integration Notes and Dependencies

This block often sits between color-space conversion and external display or compression wrappers. Integrators should document the exact format and siting expectations of neighboring modules so color shifts are not blamed on the wrong stage.

## Edge Cases, Failure Modes, and Design Risks

- A chroma-siting mismatch can create subtle but persistent color-edge displacement.
- Decimation without adequate filtering can introduce visible color aliasing.
- Packed-interface interpretation errors may only appear on odd-pixel boundaries or line transitions.

## Related Modules In This Domain

- color_space_converter
- hdmi_tx_wrapper
- video_scaler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Chroma Resampler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
