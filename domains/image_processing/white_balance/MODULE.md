# White Balance

## Overview

The white balance module applies channel-dependent gain correction so neutral scene content maps closer to equal channel levels under the current illumination. It is a central color-calibration stage in camera pipelines.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Sensor spectral response and scene illumination usually make raw or reconstructed color channels unbalanced. If those gains are not corrected, neutral objects pick up color casts and later color correction must work harder. This module provides the channel gain stage that normalizes illumination response.

## Typical Use Cases

- Applying manual or automatic white-balance gains in a camera ISP.
- Normalizing color response before color correction matrix application.
- Providing reusable channel-gain calibration in imaging and machine-vision systems.

## Interfaces and Signal-Level Behavior

- Input side accepts multi-channel color data or, in some designs, raw color-plane samples with known CFA context.
- Output side emits gain-corrected channel values with a documented clamp policy.
- Control side loads per-channel gains, selects gain banks, and chooses safe update timing.

## Parameters and Configuration Knobs

- Channel widths, gain precision, accumulator width, and clamp or rounding mode.
- Per-channel gain count, Bayer-awareness if used before demosaic, and bank-switch support.
- Runtime update policy and optional bypass mode.

## Internal Architecture and Dataflow

The block multiplies each color channel or color-plane value by its configured gain and then rounds or clamps the result into the output range. Depending on pipeline placement it may operate on raw Bayer planes or on full RGB pixels. The contract should state that placement explicitly, because the meaning of per-channel gains differs between those two cases.

## Clocking, Reset, and Timing Assumptions

White-balance gains are tied to a sensor mode, illuminant estimate, and upstream black-level state, so those dependencies should remain visible. Reset should select a known neutral or calibrated gain set.

## Latency, Throughput, and Resource Considerations

White balance is a small number of per-pixel multiplies and typically sustains one pixel per cycle with modest pipelining. Resource cost is moderate and scales with channel count and precision.

## Verification Strategy

- Compare corrected output against expected channel-gain application for several bank values.
- Check clamp and rounding behavior on bright saturated colors.
- Verify bank switching at frame boundaries and channel-order handling.

## Integration Notes and Dependencies

White balance usually precedes the color correction matrix in a standard ISP and that ordering should be documented. Integrators should also state whether gains are driven by software, AE/AWB statistics logic, or fixed calibration profiles.

## Edge Cases, Failure Modes, and Design Risks

- Applying gains designed for RGB to raw Bayer planes, or vice versa, can distort color severely.
- Gain changes mid-frame can create visible seams if not synchronized.
- Large gains may cause early clipping that later color correction cannot recover from.

## Related Modules In This Domain

- black_level_correction
- color_correction_matrix
- ae_awb_af_statistics

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the White Balance module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
