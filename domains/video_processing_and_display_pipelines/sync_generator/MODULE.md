# Sync Generator

## Overview

The sync generator creates raster timing signals such as line sync, frame sync, blanking, and active-video indication from configured geometry parameters. It is a basic but essential timing source for video pipelines and test outputs.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Many display and video subsystems need a deterministic raster schedule even when no upstream sync source exists. This module provides that schedule explicitly instead of burying porch and pulse calculations inside each output block.

## Typical Use Cases

- Generating timing for internal test patterns or display pipelines.
- Providing a raster reference for output wrappers and panel controllers.
- Serving as a reusable source of video sync in lab and production systems.

## Interfaces and Signal-Level Behavior

- Control side configures active width, active height, porches, sync widths, and polarities.
- Output side emits sync pulses, blanking, active-video flags, and optionally coordinate counters.
- Optional pixel-enable or frame-start markers can be exposed for neighboring modules.

## Parameters and Configuration Knobs

- Horizontal and vertical timing values, polarity settings, and counter widths.
- Support for coordinate outputs, runtime mode switching, and frame-start pulse style.
- Optional interlaced timing or field-ID generation.

## Internal Architecture and Dataflow

The block uses counters to track pixel and line positions and asserts outputs according to the configured timing intervals. It may also emit convenient coordinate or start-of-line markers for neighboring blocks. The documentation should define whether the coordinates correspond to active-video space or total raster space.

## Clocking, Reset, and Timing Assumptions

The pixel clock or enable cadence sets the actual temporal scale of the generated timing, so that assumption should remain visible. Reset should establish a known phase within the raster schedule, typically the start of a frame.

## Latency, Throughput, and Resource Considerations

This is lightweight timing logic with negligible arithmetic cost. Its practical importance lies in exact count behavior and deterministic mode transitions.

## Verification Strategy

- Check generated sync, blanking, and active-video intervals against the configured geometry.
- Verify coordinate outputs and any interlaced or field-ID behavior.
- Confirm reset and mode-switch transitions start on safe frame boundaries.

## Integration Notes and Dependencies

Sync generators often feed timing controllers, test-pattern generators, and display wrappers, so the meaning of their coordinates and pulses should be documented consistently. Integrators should also note whether the generator is the authoritative timing source or merely one of several possible references.

## Edge Cases, Failure Modes, and Design Risks

- A one-cycle error in porch or sync width can break downstream timing while looking nearly correct in casual inspection.
- Coordinate-space ambiguity can cause overlays and patterns to be misplaced.
- Unsafe mode changes can create mixed-raster frames.

## Related Modules In This Domain

- video_timing_controller
- panel_timing_controller
- test_pattern_generator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Sync Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
