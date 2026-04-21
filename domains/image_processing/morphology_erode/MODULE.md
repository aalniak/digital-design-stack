# Morphology Erode

## Overview

The morphology erode module shrinks asserted or bright regions according to a structuring element, removing small specks and tightening object boundaries. It is the counterpart to dilation in morphology pipelines.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Segmentation masks often contain isolated noise and ragged boundaries that need controlled shrinking rather than smoothing. Erosion performs that operation, but only if neighborhood semantics are well defined. This module packages the morphology shrink step explicitly for hardware use.

## Typical Use Cases

- Removing small noisy regions from binary masks.
- Tightening detected boundaries before measurement or labeling.
- Building reusable opening and closing morphology chains with dilation.

## Interfaces and Signal-Level Behavior

- Input side accepts binary, mask, or grayscale pixels plus raster timing.
- Output side emits the eroded raster in the same image geometry.
- Control side configures structuring element, border policy, and operating mode.

## Parameters and Configuration Knobs

- Pixel or mask width, neighborhood dimensions, structuring-element pattern, and border handling.
- Binary versus grayscale erosion mode and optional channel selection.
- Line-buffer depth and runtime kernel-bank selection if supported.

## Internal Architecture and Dataflow

The block examines the selected neighborhood and outputs the minimum or logical AND across the structuring-element support. Streaming designs use line buffers and local comparison or AND trees. The documentation should state clearly whether the output semantics are binary, grayscale, or both.

## Clocking, Reset, and Timing Assumptions

The operator assumes the upstream mask or grayscale values already encode the object or foreground meaning consistently. Reset should clear internal neighborhood state at frame boundaries.

## Latency, Throughput, and Resource Considerations

Erosion has similar cost to dilation and can usually sustain one pixel per cycle. Resource use depends on neighborhood size and whether grayscale comparisons are required.

## Verification Strategy

- Compare output against a software morphology reference for several structuring elements.
- Check border behavior, reset behavior, and binary versus grayscale mode semantics.
- Verify opening or closing pipelines pair correctly when erosion is combined with dilation.

## Integration Notes and Dependencies

Erosion often precedes dilation in opening or follows it in closing, so the shared kernel and border contracts matter. Integrators should also record whether object polarity is foreground-as-one or foreground-as-zero before using the block.

## Edge Cases, Failure Modes, and Design Risks

- An incorrect polarity assumption can make erosion behave like unintended background expansion.
- Border handling can alter region size noticeably for small objects near frame edges.
- Applying erosion too aggressively can remove valid small features that later stages expect.

## Related Modules In This Domain

- morphology_dilate
- adaptive_thresholding
- connected_components_labeler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Morphology Erode module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
