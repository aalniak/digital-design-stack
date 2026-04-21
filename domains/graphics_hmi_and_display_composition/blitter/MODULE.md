# Blitter

## Overview

Blitter copies or fills rectangular pixel regions between buffers or within a buffer, optionally applying simple format or raster operations. It provides a 2D memory-transfer primitive for display and UI workflows.

## Domain Context

A blitter is the memory-to-memory graphics mover used to copy, fill, and sometimes transform image regions without CPU-heavy pixel loops. In this domain it is a practical acceleration block for UI redraw and asset manipulation.

## Problem Solved

CPU-driven pixel copies consume bandwidth and cycles that could be offloaded to simple graphics hardware. A dedicated blitter standardizes region copy semantics, clipping, and optional raster operations in one reusable block.

## Typical Use Cases

- Copying UI regions during redraw or scrolling.
- Staging icon or panel imagery into frame buffers.
- Accelerating rectangular fills and image moves without a full GPU.
- Supporting simple 2D composition tasks in embedded HMIs.

## Interfaces and Signal-Level Behavior

- Inputs include blit descriptors with source, destination, size, stride, and optional operation controls.
- Outputs provide completion status, error reporting, and optional throughput or progress counters.
- Control interfaces configure pixel format, clipping, and fill-color or raster-op mode.
- Status signals may expose blit_busy, descriptor_invalid, and memory_fault conditions.

## Parameters and Configuration Knobs

- Supported pixel formats and stride widths.
- Maximum region size and outstanding descriptor depth.
- Copy, fill, and optional raster-op mode support.
- Transparency-key or format-conversion support if present.

## Internal Architecture and Dataflow

The blitter usually contains a descriptor interpreter, address generators, read and write burst engines, and simple per-pixel operation logic. The key contract is whether operations are strictly memory-to-memory copies, include blending or conversion, or only support a constrained subset, because software relies on that exact capability boundary.

## Clocking, Reset, and Timing Assumptions

The block assumes source and destination buffers are valid and nonconflicting under the selected operation ordering. Reset should terminate or invalidate active descriptors according to policy. If overlapping source and destination regions are allowed, copy ordering rules should be explicit.

## Latency, Throughput, and Resource Considerations

Blitters are bandwidth bound rather than arithmetic heavy. The main tradeoff is between richer 2D features and the simplicity needed to sustain predictable memory throughput. Overlap of blits with display fetch traffic is often the true system-level concern.

## Verification Strategy

- Compare copied and filled regions against a software 2D reference for several formats and strides.
- Stress overlapping source-destination regions and clipping edges.
- Verify descriptor parsing and error handling under malformed requests.
- Run concurrent display-plus-blit tests to check memory-system interaction.

## Integration Notes and Dependencies

Blitter typically shares memory infrastructure with Frame Compositor and UI software and may feed or update frame buffers used by other graphics blocks. It should align with software descriptor formats and display synchronization policy to avoid tearing.

## Edge Cases, Failure Modes, and Design Risks

- Undefined behavior on overlapping regions can create subtle redraw corruption.
- A feature-rich blitter may appear general purpose while still missing crucial format combinations used by software.
- Memory contention with live scanout can produce visible artifacts if scheduling policy is not clear.

## Related Modules In This Domain

- frame_compositor
- simple_2d_accelerator
- rectangle_fill_engine
- line_draw_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Blitter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
