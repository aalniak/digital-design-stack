# CSI-2 RX Wrapper

## Overview

The CSI-2 RX wrapper adapts a MIPI CSI-2 camera receiver or PHY-facing block into the repository's internal video-stream contracts. It hides packet, lane, and synchronization details behind a cleaner image-oriented interface.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

CSI-2 camera links carry packetized image data with lane-level and protocol-level details that most downstream image logic should not need to understand directly. This wrapper normalizes those details into a usable pixel stream and status interface.

## Typical Use Cases

- Bringing CSI-2 camera data into an FPGA or SoC image pipeline.
- Abstracting vendor-specific receiver IP behind a stable internal interface.
- Providing reusable camera-ingress glue for video and imaging projects.

## Interfaces and Signal-Level Behavior

- PHY side connects to a CSI-2 receiver or vendor IP block with lane and packet-level outputs.
- Fabric side emits pixel streams, frame and line timing, format metadata, and error status.
- Control side configures virtual channel selection, format interpretation, and reset or bring-up policy.

## Parameters and Configuration Knobs

- Lane count, supported pixel formats, virtual-channel handling, and output packing mode.
- Clocking adaptation, buffering depth, and vendor-IP wrapper selection.
- Error-report detail and runtime format or channel selection support.

## Internal Architecture and Dataflow

The wrapper collects packetized CSI-2 payloads, interprets frame and line markers, converts transport packing into raster-aligned pixel output, and propagates protocol or lane errors into a manageable status interface. It may also bridge clock domains between the receiver and the image pipeline. The contract should state exactly which receiver-IP responsibilities remain below the wrapper and which are normalized here.

## Clocking, Reset, and Timing Assumptions

The wrapper assumes the underlying PHY or receiver provides valid packetized payload data according to the selected format and lane mode. Reset and relock behavior should define when output pixels become trustworthy after a link disturbance.

## Latency, Throughput, and Resource Considerations

Most of the complexity lies in buffering, format adaptation, and error handling rather than arithmetic. Throughput must match the incoming camera payload rate continuously once the link is stable.

## Verification Strategy

- Check frame and line reconstruction against CSI-2 packet test streams and expected formats.
- Verify virtual-channel selection, error propagation, and reset or relock behavior.
- Confirm output packing and raster timing align with downstream image-processing expectations.

## Integration Notes and Dependencies

This wrapper belongs at the seam between external camera transport and internal image pipelines, so format mapping and validity semantics should be documented with it. Integrators should also state whether output timing is continuous or packet-gapped when the link stalls.

## Edge Cases, Failure Modes, and Design Risks

- A format-interpretation mismatch can create correct-looking transport statistics but wrong image pixels.
- If error conditions are not surfaced clearly, downstream image quality failures may be blamed on later stages.
- Clock-domain and link-relock handling mistakes often appear only on real hardware after disturbances.

## Related Modules In This Domain

- bayer_unpacker
- video_timing_controller
- hdmi_rx_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CSI-2 RX Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
