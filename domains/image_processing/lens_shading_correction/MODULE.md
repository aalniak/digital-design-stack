# Lens Shading Correction

## Overview

The lens shading correction module compensates for spatially varying gain falloff and color shading introduced by lens optics and sensor geometry. It is an early ISP calibration stage that restores more uniform brightness and color across the frame.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Many camera systems exhibit vignetting and color-dependent shading that cannot be fixed by one global gain. If uncorrected, these effects bias exposure, white balance, and later image analytics. This module applies the position-dependent correction map needed to flatten the field.

## Typical Use Cases

- Correcting vignetting and per-channel shading in camera pipelines.
- Applying factory or field calibration maps before demosaicing or color correction.
- Improving spatial uniformity for machine-vision measurements and display quality.

## Interfaces and Signal-Level Behavior

- Input side accepts raw or early-stage pixel streams plus line and frame markers.
- Output side emits gain-corrected pixels with preserved raster timing.
- Control side loads shading tables or grid coefficients, selects interpolation mode, and switches banks at safe boundaries.

## Parameters and Configuration Knobs

- Pixel width, gain-map precision, grid size, and interpolation strategy.
- Per-color-plane support, Bayer-order awareness, and clamp behavior after gain application.
- Bank count and runtime update synchronization.

## Internal Architecture and Dataflow

The block looks up or interpolates a local gain from a spatial correction grid and multiplies the current pixel by that gain, often selecting different gains by CFA color plane. Because the map is lower resolution than the frame, interpolation is common. The contract should specify the coordinate convention and whether correction is applied in raw or demosaiced space.

## Clocking, Reset, and Timing Assumptions

The shading map is tied to a particular lens, sensor mode, and optical state, so calibration provenance matters. Reset should select a known correction bank or bypass state before frames are processed.

## Latency, Throughput, and Resource Considerations

Lens shading correction is a moderate per-pixel multiply with map lookup and interpolation. Resource use is driven by calibration storage, position tracking, and multiplier precision.

## Verification Strategy

- Compare corrected output against a calibration reference map across the full frame.
- Check color-plane selection, grid interpolation, and bank-switch timing.
- Verify clamp and scaling behavior near bright corners where gains are largest.

## Integration Notes and Dependencies

This block generally belongs early in the raw path before statistics and color correction, and that ordering should be written down. Integrators should also document the sensor and optics mode associated with each shading table.

## Edge Cases, Failure Modes, and Design Risks

- Using a map from the wrong lens mode can worsen shading while still appearing smooth.
- Coordinate mismatches between map space and image space create spatially shifted compensation artifacts.
- Large corner gains may push bright pixels into clipping if later pipeline stages assume uncorrected headroom.

## Related Modules In This Domain

- black_level_correction
- white_balance
- bad_pixel_correction

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Lens Shading Correction module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
