# Perspective Transform

## Overview

The perspective transform applies a projective mapping between image planes or between image and normalized planar coordinates. It is used for rectification, top-down views, and geometry normalization beyond simple affine transforms.

## Domain Context

Computer-vision and perception modules convert images and intermediate features into structured scene information such as edges, objects, motion, and geometry. In this domain the key documentation topics are coordinate conventions, feature representations, confidence semantics, latency through frame and track state, and how each block expects upstream preprocessing to have normalized the visual input.

## Problem Solved

Many scenes and camera setups require projective correction rather than affine-only remapping. This module provides the homography-based geometry stage that turns image coordinates into a more useful reference frame.

## Typical Use Cases

- Generating bird's-eye or rectified planar views from camera images.
- Normalizing perspective before line or lane analysis.
- Providing reusable homography-based image remapping in perception systems.

## Interfaces and Signal-Level Behavior

- Input side accepts image data or coordinates in the source image plane.
- Output side emits remapped pixels or transformed coordinates in the destination plane.
- Control side loads homography coefficients, output geometry, and interpolation or border policy.

## Parameters and Configuration Knobs

- Coefficient precision, image dimensions, interpolation mode, and coordinate format.
- Source-to-destination versus destination-to-source mapping mode, border policy, and output precision.
- Runtime homography-bank switching and frame-synchronous update policy.

## Internal Architecture and Dataflow

The module applies a 3x3 projective transform to map between coordinate systems and uses interpolation or nearest-neighbor sampling when image resampling is required. The contract should define the coordinate normalization, homogeneous division convention, and whether coefficients map source to destination or the reverse. These details are critical to avoiding subtle geometry errors.

## Clocking, Reset, and Timing Assumptions

The homography is meaningful only for the documented camera model, image origin, and planar-scene assumption. Reset should select a known mapping bank or bypass state.

## Latency, Throughput, and Resource Considerations

Projective mapping is arithmetic- and memory-moderate, with cost dominated by coordinate evaluation and resampling access. Throughput depends on whether full-image resampling or only sparse coordinate transformation is required.

## Verification Strategy

- Compare transformed output or coordinates against a homography reference on synthetic grids and calibration images.
- Check border fill, interpolation, and coordinate convention.
- Verify frame-safe homography updates and reset behavior.

## Integration Notes and Dependencies

This block often sits near rectification, occupancy mapping, or line analysis stages, so its coordinate frame should be documented with those consumers. Integrators should also note whether the mapping is intended for visualization or metric reasoning.

## Edge Cases, Failure Modes, and Design Risks

- A source-versus-destination mapping convention mix-up can produce plausible but wrong geometry.
- If the planar-scene assumption is forgotten, downstream metric reasoning may be overconfident.
- Coordinate precision that is too low can create systematic drift in far-field regions.

## Related Modules In This Domain

- affine_warp
- occupancy_grid_builder
- stereo_matcher

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Perspective Transform module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
