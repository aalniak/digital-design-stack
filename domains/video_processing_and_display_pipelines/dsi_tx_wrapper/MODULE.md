# DSI TX Wrapper

## Overview

The DSI TX wrapper adapts internal raster video into a MIPI DSI transmit path for panel interfaces, abstracting packet formatting and platform-specific transmit details behind a stable display-facing contract. It is targeted at embedded display systems rather than monitor-style links.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Panel interfaces often use DSI transport with its own packet and timing conventions, while the rest of the display pipeline works in raster terms. This wrapper bridges those worlds so panel-facing details do not leak into the core video pipeline.

## Typical Use Cases

- Driving embedded panels that use a DSI interface.
- Abstracting DSI TX vendor IP behind a raster-based internal interface.
- Providing reusable panel egress glue for mobile and embedded display designs.

## Interfaces and Signal-Level Behavior

- Video side accepts pixel raster, sync timing, and mode metadata from internal display logic.
- Transport side connects to a DSI TX core or PHY-specific wrapper.
- Control side configures display mode, lane or packet settings, and reset or enable sequencing.

## Parameters and Configuration Knobs

- Pixel format support, packetization mode, buffering depth, and lane-configuration profile.
- Clock adaptation, burst versus nonburst behavior, and runtime mode-switch policy.
- Status-report coverage and whether command-mode control is included or left external.

## Internal Architecture and Dataflow

The wrapper reformats raster pixel data into the payload structure expected by the DSI transmit block, aligns timing with panel mode requirements, and normalizes status back to the internal pipeline. Some designs also coordinate command-mode and video-mode interactions. The documentation should specify what part of that responsibility stays inside this wrapper.

## Clocking, Reset, and Timing Assumptions

The lower TX core is assumed to manage the physical DSI protocol details while this wrapper manages raster adaptation and mode coordination. Reset should define the safe panel-output state before valid video is transmitted.

## Latency, Throughput, and Resource Considerations

The wrapper is mostly control and adaptation logic, but it must preserve line and frame timing accurately at panel rate. Resource use is moderate and driven by packing and buffering.

## Verification Strategy

- Check pixel packing and line or frame adaptation against supported panel modes.
- Verify reset, enable sequencing, and mode-switch boundaries.
- Confirm that panel-facing readiness and fault status are surfaced cleanly to the rest of the system.

## Integration Notes and Dependencies

This wrapper should be documented together with panel timing requirements and any separate panel-initialization logic. Integrators should also state whether command-mode writes are part of this module or handled elsewhere.

## Edge Cases, Failure Modes, and Design Risks

- If panel mode assumptions are incomplete, video may appear mostly correct but with subtle line or frame instability.
- Unsafe enable sequencing can confuse panels even when the raster path is correct.
- Format mismatches are easy to misdiagnose because DSI transport may remain healthy while colors are wrong.

## Related Modules In This Domain

- panel_timing_controller
- video_timing_controller
- displayport_tx_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DSI TX Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
