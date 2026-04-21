# Frame Buffer Reader

## Overview

The frame buffer reader fetches raster image data from memory and presents it as a timed video stream with deterministic line and frame boundaries. It is the core memory-to-video bridge used by many display and compositing systems.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Memory stores frames as addressable data, while display and video pipelines need continuous raster timing. A frame buffer reader converts between those worlds, but it must define addressing, stride, underflow, and sync behavior carefully. This module provides that bridge explicitly.

## Typical Use Cases

- Driving a display from a stored frame in DDR or SRAM.
- Supplying background or overlay layers to a compositor.
- Reading captured or generated frames back into a timed video pipeline.

## Interfaces and Signal-Level Behavior

- Memory side issues read bursts against a frame store with stride and format awareness.
- Video side emits raster pixels with line and frame markers and optional underflow status.
- Control side configures base address, geometry, stride, format, and page or buffer selection.

## Parameters and Configuration Knobs

- Frame dimensions, stride, burst size, pixel format, and buffering depth.
- Memory-bus width, page-flip support, and underflow policy.
- Color format and planar versus packed layout handling.

## Internal Architecture and Dataflow

The block walks memory addresses according to the configured frame layout, prefetches pixel data into line or burst buffers, and releases pixels at video cadence. It often supports double buffering or page flipping to allow frame updates without tearing. The contract should specify what happens when the memory subsystem cannot supply data fast enough.

## Clocking, Reset, and Timing Assumptions

The configured memory layout and pixel format must match the stored frame exactly, and the display timing consumer must define the target raster cadence. Reset should clear buffers and choose a known starting page or blanking behavior.

## Latency, Throughput, and Resource Considerations

Frame reading is fundamentally bandwidth bound, with buffering used to smooth bursty memory service into continuous raster output. Resource use is shaped by prefetch depth and format adaptation logic.

## Verification Strategy

- Check raster output against known stored-frame patterns across several strides and formats.
- Verify underflow behavior, page switching, and line-address progression.
- Confirm reset and start-of-frame sequencing so no stale memory data leaks into a new frame.

## Integration Notes and Dependencies

This block usually sits between a memory scheduler and a display or compositor stage, so integrators should document bandwidth assumptions and whether page flips are frame synchronous. They should also define whether underflow produces blank pixels, repeated last pixels, or a fault indication only.

## Edge Cases, Failure Modes, and Design Risks

- A stride or format mismatch can produce partially correct images that are hard to debug.
- Insufficient prefetch depth may only fail on heavy-memory-contention scenes.
- Page switching outside a safe boundary can create tearing even when the reader itself is otherwise correct.

## Related Modules In This Domain

- frame_buffer_writer
- compositor
- video_timing_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frame Buffer Reader module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
