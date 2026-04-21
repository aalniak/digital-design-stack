# HDR Tone Mapper

## Overview

The HDR tone mapper compresses or remaps high-dynamic-range image content into a lower dynamic range appropriate for a display or downstream stage while preserving perceptual detail as much as possible. It is a tone-management stage rather than a simple gamma curve.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

HDR imagery contains luminance relationships that cannot be displayed or processed directly in limited dynamic-range systems. A tone mapper makes those values usable, but the mapping policy, metadata dependence, and color interaction must be explicit. This module packages that adaptation step.

## Typical Use Cases

- Preparing HDR content for SDR or limited-luminance displays.
- Applying scene- or frame-dependent tone curves in a video pipeline.
- Providing reusable tone-compression for high-dynamic-range camera or playback systems.

## Interfaces and Signal-Level Behavior

- Input side accepts HDR-like pixel values and any required luminance or metadata sideband.
- Output side emits tone-mapped pixels in the target range with preserved raster timing.
- Control side configures global or local tone-mapping mode, metadata use, and output range policy.

## Parameters and Configuration Knobs

- Input and output precision, tone-map curve representation, and metadata interface width.
- Global versus locally adaptive mode, highlight handling, and channel or luma-only mapping policy.
- Runtime curve updates and frame-synchronous bank switching.

## Internal Architecture and Dataflow

The block applies a tone-compression function, often based on luminance estimates, metadata, or programmable curves, then reconstructs output channel values with careful clamp and color-preservation rules. Some designs are purely global LUT-driven, while others adapt by region or scene statistics. The documentation should state which class of tone mapping is implemented and how color channels are preserved during luminance compression.

## Clocking, Reset, and Timing Assumptions

Tone mapping is meaningful only relative to a documented HDR encoding, color space, and target display range, so those assumptions should remain visible. Reset should select a known safe tone curve or bypass state.

## Latency, Throughput, and Resource Considerations

Simple global tone mapping is moderate in cost, while local adaptation can be considerably heavier due to statistics and neighborhood memory. Throughput must still track full pixel rate.

## Verification Strategy

- Compare output against a reference tone-mapping implementation for several HDR scenes and metadata cases.
- Check highlight roll-off, black-level handling, and frame-boundary curve updates.
- Verify that color preservation behaves as documented when luminance is compressed strongly.

## Integration Notes and Dependencies

This block usually sits late in the video pipeline before final display-oriented gamma or transport formatting. Integrators should document the exact HDR encoding and target range assumptions used to tune it.

## Edge Cases, Failure Modes, and Design Risks

- Applying the wrong input encoding assumptions can make tone mapping look plausible but systematically wrong.
- Local adaptation may introduce pumping or halo-like artifacts if not designed carefully.
- If color preservation is underspecified, saturated highlights may shift hue unexpectedly.

## Related Modules In This Domain

- gamma_lut
- clahe_engine
- video_scaler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the HDR Tone Mapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
