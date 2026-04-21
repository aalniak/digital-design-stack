# HDMI TX Wrapper

## Overview

The HDMI TX wrapper adapts internal raster video into the interface required by an HDMI transmitter or vendor IP block. It isolates transport-facing details from the core video pipeline while preserving mode and timing semantics.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Internal video logic works in pixel and sync terms, whereas HDMI output cores expect transport-specific formatting and mode coordination. This wrapper bridges those worlds so display egress stays reusable.

## Typical Use Cases

- Driving TVs, monitors, or capture devices over HDMI.
- Abstracting HDMI TX vendor IP behind a stable raster-stream contract.
- Providing reusable display output glue in video and graphics systems.

## Interfaces and Signal-Level Behavior

- Video side accepts raster pixels, sync markers, and mode metadata.
- Transport side connects to an HDMI TX core or wrapper with transmitter-facing signals.
- Control side configures output mode, reset sequencing, and status gating or mute behavior.

## Parameters and Configuration Knobs

- Supported output formats, packing style, buffering depth, and clock-adaptation profile.
- Mode-switch policy, color format support, and optional auxiliary-feature exposure.
- Status-report detail such as active-video enable and link-ready signaling.

## Internal Architecture and Dataflow

The wrapper reformats and times internal raster video for the lower HDMI transmit core, normalizing mode selection and status along the way. Depending on platform, electrical and encoding details remain below the wrapper, while video packing and readiness gating live inside it. The contract should define that split clearly.

## Clocking, Reset, and Timing Assumptions

The underlying TX IP is assumed to own electrical compliance and low-level protocol behavior. Reset should establish a known blank or muted output state until a valid video mode is active.

## Latency, Throughput, and Resource Considerations

The wrapper must keep up with the target pixel clock continuously but is otherwise mostly control and adaptation logic. Resource use depends on buffering and packing complexity.

## Verification Strategy

- Check pixel packing, sync mapping, and mode changes against the expected TX-core interface.
- Verify blanking or mute behavior around reset and invalid-input conditions.
- Confirm frame-boundary safety for any runtime output-mode changes.

## Integration Notes and Dependencies

This wrapper often sits near timing generators and display mode control, so those modules should share a documented mode contract. Integrators should also note whether audio or infoframe management is in scope or external.

## Edge Cases, Failure Modes, and Design Risks

- Unsafe mode changes can create mixed or unstable output frames.
- A color-format mismatch may remain hidden until displayed on a real sink.
- If invalid-video gating is unclear, sinks may lock to unstable output timing.

## Related Modules In This Domain

- video_timing_controller
- displayport_tx_wrapper
- panel_timing_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the HDMI TX Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
