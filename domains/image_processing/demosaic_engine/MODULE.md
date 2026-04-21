# Demosaic Engine

## Overview

The demosaic engine reconstructs full-color pixels from a raw Bayer or similar color-filter-array image by estimating the missing color components at each pixel location. It is one of the most important stages in a camera ISP because it defines much of the resulting color detail and artifact profile.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Raw sensor data contains only one color sample per pixel location, but later stages and displays need full-color pixels. Demosaicing fills in the missing channels, and the algorithm choice strongly affects edge quality, color fidelity, and zipper artifacts. This module encapsulates that reconstruction step.

## Typical Use Cases

- Converting raw Bayer streams into RGB for ISP and display pipelines.
- Providing a reusable color reconstruction stage in camera and machine-vision systems.
- Supporting research evaluation of demosaic quality and artifact tradeoffs in hardware.

## Interfaces and Signal-Level Behavior

- Input side accepts raw CFA pixels plus line and frame markers and a documented Bayer order.
- Output side emits full-color pixels, usually RGB, with preserved raster timing and a defined border policy.
- Control side selects algorithm mode, Bayer pattern, and optional quality-versus-resource tradeoff settings.

## Parameters and Configuration Knobs

- Pixel width, Bayer order, interpolation precision, and border handling.
- Algorithm profile, line-buffer depth, and output color format.
- Runtime Bayer-order selection and frame-synchronous update policy.

## Internal Architecture and Dataflow

The engine uses local neighborhoods and CFA position to estimate the missing color channels at each pixel. Simple designs interpolate separately in each direction, while richer ones use edge-directed logic to reduce color artifacts near detail boundaries. The documentation should state the chosen reconstruction strategy and whether output color channels are aligned to raw sample centers or another convention.

## Clocking, Reset, and Timing Assumptions

Input raw data must already be unpacked, bias corrected, and reasonably free of bad-pixel outliers for best results. Reset should clear neighborhood state and line buffers so color reconstruction restarts on a clean frame boundary.

## Latency, Throughput, and Resource Considerations

Demosaicing is moderately expensive because it needs neighborhood context and several interpolation paths, but streaming one-pixel-per-cycle implementations are common. Resource use is dominated by line buffers, adders, and interpolation control logic.

## Verification Strategy

- Compare RGB output against a software demosaic reference over known Bayer patterns and test images.
- Check border policy, Bayer-order selection, and line-buffer reset behavior.
- Verify edge-directed or quality modes match the documented artifact-versus-cost tradeoff.

## Integration Notes and Dependencies

This block typically sits after raw cleanup stages such as black-level and bad-pixel correction and before color correction or white balance, depending on pipeline design. Integrators should document that ordering explicitly because it changes output appearance and calibration semantics.

## Edge Cases, Failure Modes, and Design Risks

- Using the wrong Bayer order can create severe color artifacts that contaminate every later stage.
- Border and line-buffer mistakes may only show up on the first few lines of a frame.
- Algorithm changes that improve visual quality for humans may alter statistics relied on by machine-vision models.

## Related Modules In This Domain

- bayer_unpacker
- white_balance
- color_correction_matrix

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Demosaic Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
