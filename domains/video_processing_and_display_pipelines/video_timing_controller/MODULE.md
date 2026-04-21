# Video Timing Controller

## Overview

The video timing controller generates or manages the canonical raster timing signals that define active video, blanking, sync periods, and sometimes pixel coordinates for a chosen video mode. It is the timing backbone for many display-oriented pipelines.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Every display and many capture systems need a shared definition of where each line and frame begins and ends. A reusable timing controller centralizes that mode geometry so individual blocks do not carry their own private porch and sync logic.

## Typical Use Cases

- Providing timing for display output pipelines and panel controllers.
- Supplying raster coordinates and blanking to overlays, mixers, and pattern generators.
- Serving as the authoritative mode source in a video subsystem.

## Interfaces and Signal-Level Behavior

- Control side configures active dimensions, porches, sync widths, polarity, and mode selection.
- Output side emits sync, blanking, active-video, coordinate counters, and optional frame-start markers.
- Optional input side may accept an external enable or mode-advance trigger for managed timing changes.

## Parameters and Configuration Knobs

- Horizontal and vertical mode geometry, polarity settings, and coordinate counter widths.
- Runtime mode-switch support, interlaced-mode support, and frame-start pulse style.
- Optional coordinate outputs in active-only or full-raster space.

## Internal Architecture and Dataflow

The controller uses horizontal and vertical counters to traverse the configured raster and derives all timing outputs from those counts. In many systems it also provides convenient coordinate outputs used by overlays and pattern generators. The documentation should say whether it is the master timing source or a timing-management block around another source.

## Clocking, Reset, and Timing Assumptions

The pixel clock or pixel-enable cadence defines the real-time duration of the generated mode, so that relationship should remain explicit. Reset should establish a known raster phase, usually the start of frame or line zero.

## Latency, Throughput, and Resource Considerations

This is small control logic with negligible arithmetic complexity, but every count and transition must be exact. Resource use is minimal and mostly counter and compare logic.

## Verification Strategy

- Check sync, blanking, active-video, and coordinate outputs against the configured mode specification.
- Verify interlaced or field behavior if supported.
- Confirm reset and runtime mode changes occur at documented safe boundaries.

## Integration Notes and Dependencies

The timing controller often serves as shared infrastructure for several display blocks, so coordinate-space and mode semantics should be documented centrally here. Integrators should also state whether any external sink or capture block may override its timing.

## Edge Cases, Failure Modes, and Design Risks

- A one-count error anywhere in the mode geometry can invalidate an otherwise healthy display pipeline.
- Coordinate interpretation differences between active-only and full-raster spaces can misplace overlays and test patterns.
- Mode switches without a strict safe point can create mixed-timing frames.

## Related Modules In This Domain

- sync_generator
- panel_timing_controller
- test_pattern_generator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Video Timing Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
