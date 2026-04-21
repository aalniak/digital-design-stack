# AE AWB AF Statistics Engine

## Overview

The AE AWB AF statistics engine computes exposure, white-balance, and focus metrics from image frames so camera control algorithms can tune the sensor and ISP settings intelligently. It is a control-support block rather than a direct image-transform stage.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Auto-exposure, auto-white-balance, and autofocus algorithms depend on frame statistics, but those statistics must be gathered consistently and often at full image rate. This module provides the measurement backbone those control loops rely on.

## Typical Use Cases

- Providing real-time image statistics to camera-control firmware or hardware loops.
- Supporting experimental imaging pipelines that need exposure and focus feedback.
- Generating region-of-interest metrics for ISP tuning and camera bring-up.

## Interfaces and Signal-Level Behavior

- Input side accepts raw or partially processed pixel data plus line and frame markers and optional region metadata.
- Output side emits accumulated statistics per frame, tile, or region for exposure, color balance, and focus estimation.
- Control side configures windows, ROI selection, color extraction mode, and statistic types to accumulate.

## Parameters and Configuration Knobs

- Pixel format, tile grid or ROI geometry, accumulator widths, and supported focus metrics.
- Exposure histogram or sum mode, color-channel selection, and frame-report timing.
- Support for several simultaneous ROIs or statistic banks.

## Internal Architecture and Dataflow

The engine typically accumulates luminance sums, histograms, color-channel ratios, and focus-energy metrics such as gradients or high-frequency content over selected regions. The outputs are latched at frame end or region boundaries and consumed by control software or hardware loops. The contract should define precisely which pixel representation the statistics operate on and whether results are global, tiled, or ROI-specific.

## Clocking, Reset, and Timing Assumptions

Statistic meaning depends heavily on where the block sits in the image pipeline and whether pixels are raw Bayer, demosaiced RGB, or another representation. Reset should clear all accumulators cleanly so frame reports start from zeroed state.

## Latency, Throughput, and Resource Considerations

Statistics engines must often keep up with full sensor rate, but the arithmetic is usually sums, comparisons, and simple gradients rather than heavy transforms. Resource use grows with the number of simultaneous regions and metrics.

## Verification Strategy

- Compare reported statistics against a software reference over known image frames and ROIs.
- Check frame-boundary latching, accumulator reset, and tile indexing.
- Verify metric interpretation for several input pixel formats and color orderings.

## Integration Notes and Dependencies

This block usually sits on the control boundary between the image stream and camera-tuning logic, so statistic definitions should be documented for firmware teams explicitly. Integrators should also state which version of the image stream the metrics observe.

## Edge Cases, Failure Modes, and Design Risks

- If the metric definitions differ from software expectations, control loops may tune the wrong behavior despite receiving valid numbers.
- ROI indexing errors can make camera tuning seem unstable only on certain scenes.
- Accumulator overflow on bright or large regions can silently bias exposure decisions.

## Related Modules In This Domain

- adaptive_thresholding
- bayer_unpacker
- black_level_correction

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the AE AWB AF Statistics Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
