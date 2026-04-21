# Black Level Correction

## Overview

The black level correction module subtracts sensor-dependent baseline offsets from raw pixels so zero light corresponds more closely to zero code after correction. It is an early ISP stage that improves dynamic-range usage and color accuracy for every downstream block.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Image sensors often produce nonzero outputs even in darkness due to bias and readout offsets. If those offsets are not removed early, later demosaicing, white balance, and statistics are all biased. This module centralizes that offset removal step.

## Typical Use Cases

- Normalizing raw sensor output before bad-pixel correction and demosaicing.
- Applying per-channel or per-color-plane baseline subtraction in camera pipelines.
- Improving dark-level consistency for machine vision and measurement imaging systems.

## Interfaces and Signal-Level Behavior

- Input side accepts raw pixel streams and line or frame markers, often still in Bayer form.
- Output side emits corrected pixels with the same raster timing and a documented clamp policy for underflow.
- Control side loads black-level offsets globally or per color plane and may select calibration banks.

## Parameters and Configuration Knobs

- Pixel width, offset width, per-plane versus global correction mode, and clamp behavior.
- Supported Bayer order or channel tagging mode, and optional gain after subtraction.
- Runtime bank-switch or frame-boundary update policy.

## Internal Architecture and Dataflow

The block subtracts configured bias values from incoming raw pixels, often selecting among several offsets according to Bayer position or channel identity. Underflow is typically clamped to zero or a small floor value. The contract should define whether offsets are signed, how they are aligned to the pixel code range, and when new offsets become active relative to frame boundaries.

## Clocking, Reset, and Timing Assumptions

Offsets are meaningful only for a specific sensor mode, gain, and temperature context, so their provenance belongs with the configuration. Reset should select a documented default offset set or safe bypass behavior.

## Latency, Throughput, and Resource Considerations

This stage is computationally cheap and usually sustains one pixel per cycle. Resource use is small, dominated by offset storage and Bayer-position tracking if several offsets are supported.

## Verification Strategy

- Compare corrected output against expected subtraction behavior for each supported plane or channel.
- Check underflow clamp policy and offset-bank switching at frame boundaries.
- Verify that Bayer-position tracking remains correct across line and frame resets.

## Integration Notes and Dependencies

Black level correction generally belongs immediately after unpacking and before almost every other ISP stage. Integrators should document the sensor operating modes associated with each offset set and whether software may update them live.

## Edge Cases, Failure Modes, and Design Risks

- Applying the wrong color-plane offsets can create color casts that only become obvious after demosaicing.
- If underflow handling is not explicit, later stages may interpret wrapped values as bright pixels.
- Offset updates mid-frame can create visible seam artifacts if not frame synchronized.

## Related Modules In This Domain

- bayer_unpacker
- bad_pixel_correction
- white_balance

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Black Level Correction module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
