# Line Buffer

## Overview

line_buffer stores one or more lines of raster-ordered or row-major data so nearby processing stages can access a moving local neighborhood without needing the full frame resident. It is the sliding-window storage primitive for line-oriented pipelines.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Many image, video, and stencil algorithms need recent rows rather than complete frames. A reusable line_buffer avoids repeated custom shift and address logic while making neighborhood availability explicit.

## Typical Use Cases

- Support convolution, edge detection, or neighborhood filters.
- Stage recently received rows ahead of a streaming image pipeline.
- Provide local row reuse in stencil or raster algorithms.

## Interfaces and Signal-Level Behavior

- Inputs usually accept raster-ordered data plus line or frame markers.
- Outputs may expose current taps, neighborhood windows, or read addresses relative to recent rows.
- Status may indicate line complete, valid window, or frame reset state.

## Parameters and Configuration Knobs

- DATA_WIDTH sets stored element width.
- LINE_LENGTH defines row capacity.
- NUM_LINES sets how many previous rows are retained.
- WINDOW_ACCESS_MODE selects full-window or tap-based output.
- PADDING_POLICY defines behavior at row or frame edges.

## Internal Architecture and Dataflow

A line buffer typically uses one or more memory rows plus address counters and tap logic that align the current input position with prior-row data. The key contract detail is when a full valid neighborhood becomes available and how boundaries are handled before enough history exists.

## Clocking, Reset, and Timing Assumptions

The incoming order must be consistent and documented, usually raster left-to-right with explicit row boundaries. Reset or frame restart should invalidate prior-line history unless the design intentionally supports continuous tiling across frames.

## Latency, Throughput, and Resource Considerations

Line buffers can usually sustain one sample per cycle because they are designed for streaming locality. Resource cost is driven by line length, number of retained rows, and the width of any exposed neighborhood window.

## Verification Strategy

- Check window validity timing at startup and after each frame reset.
- Exercise row-end and frame-end boundary conditions.
- Verify tap ordering and neighborhood contents against a reference model.
- Stress line lengths that are not powers of two or other implementation-friendly sizes.

## Integration Notes and Dependencies

line_buffer commonly precedes image filters, stencil engines, and row-based video processing. It complements frame_buffer by providing short-term local reuse rather than whole-frame storage.

## Edge Cases, Failure Modes, and Design Risks

- Boundary handling is the dominant functional risk.
- Tap ordering errors often produce plausible but spatially shifted results.
- Assumptions about raster order must match the upstream source exactly.

## Related Modules In This Domain

- frame_buffer
- circular_buffer
- ping_pong_buffer
- dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Line Buffer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
