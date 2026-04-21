# Stereo Matcher

## Overview

The stereo matcher estimates disparity between rectified left and right images, producing the raw depth cue used by later 3D reasoning blocks. It is one of the central geometry modules in stereo vision.

## Domain Context

Computer-vision and perception modules convert images and intermediate features into structured scene information such as edges, objects, motion, and geometry. In this domain the key documentation topics are coordinate conventions, feature representations, confidence semantics, latency through frame and track state, and how each block expects upstream preprocessing to have normalized the visual input.

## Problem Solved

Depth from stereo requires finding correspondences between two views under a rectified geometry assumption, but that matching process is computationally expensive and sensitive to texture, occlusion, and cost-function details. This module provides the reusable stereo correspondence stage.

## Typical Use Cases

- Generating disparity maps from rectified stereo camera pairs.
- Supplying depth cues to occupancy, obstacle, or 3D reconstruction logic.
- Providing reusable stereo depth infrastructure in embedded vision systems.

## Interfaces and Signal-Level Behavior

- Input side accepts synchronized left and right image streams in a documented rectified geometry.
- Output side emits disparity values, costs or confidence, and optional invalid masks.
- Control side configures disparity range, matching window or cost mode, and uniqueness or consistency thresholds.

## Parameters and Configuration Knobs

- Image dimensions, disparity width, disparity search range, and cost precision.
- Matching-window size, subpixel support, and confidence output mode.
- Runtime parameter updates and invalid-disparity coding.

## Internal Architecture and Dataflow

The matcher computes a matching cost between left and right image neighborhoods over a disparity search range, selects the best disparity according to the chosen criterion, and emits that result with any optional confidence or uniqueness metric. The contract should define whether disparity is left-referenced or right-referenced, whether outputs are integer or subpixel, and what invalid coding is used.

## Clocking, Reset, and Timing Assumptions

The input images must be rectified and synchronized according to the documented camera geometry. Reset should clear any line or cost-buffer state so the next frame restarts cleanly.

## Latency, Throughput, and Resource Considerations

Stereo matching is often one of the heaviest perception stages because cost volume or search logic scales with image width and disparity range. Resource use depends strongly on the chosen cost model and output precision.

## Verification Strategy

- Compare disparity output against a stereo reference implementation on synthetic and recorded stereo pairs.
- Check disparity direction convention, invalid-value coding, and confidence output.
- Verify frame resets and boundary handling, especially near the start of lines where search context is limited.

## Integration Notes and Dependencies

This block often feeds disparity refinement, occupancy grids, or 3D reasoning, so its disparity scale and reference-view convention should be documented with those consumers. Integrators should also state whether confidence or left-right checks are handled here or later.

## Edge Cases, Failure Modes, and Design Risks

- A left-versus-right disparity convention mismatch can invert depth interpretation downstream.
- Disparity range that is too narrow will silently clip near objects.
- If rectification assumptions are violated upstream, the matcher may fail in ways that resemble implementation bugs.

## Related Modules In This Domain

- disparity_refiner
- occupancy_grid_builder
- perspective_transform

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Stereo Matcher module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
