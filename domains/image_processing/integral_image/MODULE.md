# Integral Image

## Overview

The integral image module computes a summed-area table so rectangular region sums can be evaluated later with constant-time arithmetic rather than scanning all enclosed pixels. It is a structural accelerator for several image-analysis algorithms.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Many local-aggregation algorithms need repeated sums over rectangular windows, which are expensive if recomputed pixel by pixel. An integral image turns that cost into a one-time prefix computation followed by cheap lookups. This module provides that reusable precomputation stage.

## Typical Use Cases

- Accelerating box filters and local-threshold statistics.
- Supporting Haar-like feature extraction or summed-region measurement.
- Providing reusable rectangle-sum infrastructure for perception pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts scalar pixels with line and frame timing.
- Output side emits the integral-value stream or stores it into a memory-backed representation for later consumers.
- Control side configures image geometry, numeric precision, and whether output is streamed or buffered.

## Parameters and Configuration Knobs

- Pixel width, accumulator width, frame dimensions, and output format.
- Streaming versus memory-backed organization and border initialization policy.
- Optional multi-channel support or ROI-limited operation.

## Internal Architecture and Dataflow

The block computes each integral value as the sum of the current pixel, the previous integral value in the same line, and the integral value from the previous line, minus the overlapping corner term. This requires line buffering and wide accumulation. The contract should state where the origin and zero border are defined, because later rectangle-sum formulas depend on that convention exactly.

## Clocking, Reset, and Timing Assumptions

Accumulator width must be chosen for the worst-case frame size and pixel range, since overflow invalidates the entire table. Reset should clear line state so the next frame begins with a clean zero border.

## Latency, Throughput, and Resource Considerations

Integral images can be generated at one pixel per cycle with modest arithmetic, but accumulator widths can be large. Resource use is dominated by line buffers and wide adders.

## Verification Strategy

- Compare emitted integral values against a reference implementation on several frame sizes and patterns.
- Check origin convention, border handling, and accumulator overflow protection.
- Verify frame resets and line transitions so no stale prefix state leaks across boundaries.

## Integration Notes and Dependencies

This block is often paired with adaptive thresholding, box filtering, or feature extraction, and all of those consumers must share the same coordinate convention. Integrators should document whether the integral output is immediate-use only or persisted in memory for later random access.

## Edge Cases, Failure Modes, and Design Risks

- An off-by-one error in origin convention breaks every downstream rectangle sum.
- Accumulator overflow may only appear on bright, large frames and can quietly poison derived statistics.
- If line-buffer resets are wrong, only the first few rows of each frame may be corrupt, making the bug subtle.

## Related Modules In This Domain

- adaptive_thresholding
- histogram_engine
- feature_extractor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Integral Image module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
