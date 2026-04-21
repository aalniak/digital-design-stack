# Frame Buffer Writer

## Overview

The frame buffer writer captures a video stream and stores it into memory in a documented raster layout. It is the timed-video-to-memory counterpart of the frame buffer reader.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Video streams arrive with line and frame cadence, while memory prefers bursts and addressable layout. A frame buffer writer must buffer, pack, and stride those pixels correctly while handling frame boundaries and overflow conditions. This module provides that structured write path.

## Typical Use Cases

- Recording incoming video to DDR for later display or analysis.
- Capturing rendered or processed frames into memory for page flipping or software access.
- Serving as a reusable raster sink in video pipelines.

## Interfaces and Signal-Level Behavior

- Video side accepts timed raster pixels, sync markers, and optional format metadata.
- Memory side issues write bursts into a configured frame layout.
- Control side sets base address, stride, frame geometry, format, and buffering or page-select policy.

## Parameters and Configuration Knobs

- Frame dimensions, stride, burst length, pixel format, and internal buffering depth.
- Memory-bus width, planar versus packed layout, and overflow policy.
- Page-rotation support and frame-synchronous address switching behavior.

## Internal Architecture and Dataflow

The block accumulates incoming raster data into memory-bus-friendly bursts, maps each line and pixel position into the configured address space, and writes the frame into memory according to stride and format rules. The documentation should define what happens on overflow or if the writer is disabled mid-frame, because those cases determine whether memory contents remain coherent.

## Clocking, Reset, and Timing Assumptions

The incoming raster timing must match the configured frame geometry, and the destination memory system must deliver sufficient bandwidth. Reset should clear write buffers and select a known target page or safe discard mode.

## Latency, Throughput, and Resource Considerations

Like the reader, this block is bandwidth dominated and relies on buffering to translate continuous raster timing into burst writes. Resource use depends on burst staging and format packing complexity.

## Verification Strategy

- Check memory contents against expected raster layouts for several formats and strides.
- Verify overflow, frame abort, and page-switch behavior.
- Confirm that line and frame markers map to the correct memory addresses without off-by-one errors.

## Integration Notes and Dependencies

This module is often paired with frame readers, captures, and software consumers, so the stored format should be documented exactly. Integrators should also state whether incomplete frames are considered valid or discarded on faults.

## Edge Cases, Failure Modes, and Design Risks

- Addressing mistakes can produce apparently valid memory traffic while corrupting frame layout subtly.
- Overflow policy that is not explicit can leave half-written frames in memory.
- If page changes are not frame synchronized, captured content may tear between pages.

## Related Modules In This Domain

- frame_buffer_reader
- storage_dma_engine
- video_timing_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frame Buffer Writer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
