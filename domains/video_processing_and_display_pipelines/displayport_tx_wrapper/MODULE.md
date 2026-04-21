# DisplayPort TX Wrapper

## Overview

The DisplayPort TX wrapper adapts an internal video stream to a DisplayPort transmitter or PHY-facing block, hiding protocol and vendor-IP specifics behind a cleaner raster-oriented interface. It is the display egress companion to other transport wrappers in the stack.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

DisplayPort output requires packetization, timing adaptation, and link-specific coordination that most internal video logic should not deal with directly. This wrapper separates those concerns from the core video pipeline.

## Typical Use Cases

- Driving monitors or embedded displays over DisplayPort.
- Abstracting a vendor DisplayPort TX core behind a stable internal interface.
- Providing reusable display egress glue in high-resolution video systems.

## Interfaces and Signal-Level Behavior

- Video side accepts raster pixel streams, sync timing, and format metadata.
- Transport side connects to a DisplayPort TX core or vendor IP with protocol-facing signals.
- Control side configures mode, link status handling, and reset or training interaction.

## Parameters and Configuration Knobs

- Supported video formats, pixel packing mode, buffering depth, and transport wrapper profile.
- Clock-domain adaptation, color format support, and runtime mode switching limits.
- Status-report detail and whether audio or auxiliary features are included or left external.

## Internal Architecture and Dataflow

The wrapper converts the internal raster-oriented representation into the format required by the lower DisplayPort TX block, handling packing, timing adaptation, and status normalization. Depending on platform, training and lane management may live mostly below the wrapper while raster adaptation lives here. The contract should state clearly where the boundary lies.

## Clocking, Reset, and Timing Assumptions

The underlying TX IP is assumed to own electrical and link-layer compliance behavior, while the wrapper owns correct raster adaptation and status propagation. Reset should define when output video becomes valid relative to link-training status.

## Latency, Throughput, and Resource Considerations

The wrapper itself is mostly adaptation logic, but it must sustain the target pixel rate continuously. Resource use is shaped by buffering and clock-domain bridging rather than arithmetic.

## Verification Strategy

- Check raster timing and pixel packing against the expected TX-core interface for supported modes.
- Verify reset, link-up gating, and status propagation under normal and disturbed conditions.
- Confirm format and mode changes occur only at safe frame boundaries if that is the contract.

## Integration Notes and Dependencies

This wrapper sits at the seam between internal video pipelines and platform-specific output IP, so it should be documented together with the supported display modes. Integrators should also state whether audio and auxiliary side channels are part of this wrapper or separate blocks.

## Edge Cases, Failure Modes, and Design Risks

- If the boundary between wrapper and TX IP is vague, ownership of status and timing bugs becomes unclear.
- Unsafe mode switching can create partially mixed frames at the output.
- Clock-domain assumptions that work in one display mode may fail in another.

## Related Modules In This Domain

- hdmi_tx_wrapper
- video_timing_controller
- panel_timing_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DisplayPort TX Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
