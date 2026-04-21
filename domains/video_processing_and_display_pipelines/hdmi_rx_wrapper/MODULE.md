# HDMI RX Wrapper

## Overview

The HDMI RX wrapper adapts an HDMI receiver or vendor IP block into the repository's internal video-stream format, hiding protocol-specific details behind a cleaner raster-oriented interface. It is the display-input counterpart to the HDMI TX wrapper.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

HDMI ingress brings pixel transport, timing recovery, and format metadata that most image or video stages should not consume directly. This wrapper normalizes those details into a stable internal contract.

## Typical Use Cases

- Capturing external HDMI video into a processing or display pipeline.
- Abstracting vendor HDMI RX IP behind a stable internal stream interface.
- Providing reusable video ingress glue for FPGA and SoC designs.

## Interfaces and Signal-Level Behavior

- Transport side connects to an HDMI RX core or vendor IP with protocol-facing signals.
- Video side emits raster pixels, sync markers, format metadata, and error status.
- Control side configures mode interpretation, reset, and status or lock handling.

## Parameters and Configuration Knobs

- Supported pixel formats, input packing modes, buffering depth, and wrapper profile.
- Clock-domain adaptation, color-space metadata handling, and runtime mode-change limits.
- Error and status-report detail, including lock or timing-valid indications.

## Internal Architecture and Dataflow

The wrapper converts receiver-oriented outputs into the internal raster stream used by the rest of the repository, preserving or translating sync and format metadata as needed. It may also cross from a recovered or receiver-specific clock domain into a fabric video domain. The contract should state exactly when the output stream is considered valid after HDMI lock.

## Clocking, Reset, and Timing Assumptions

The underlying RX IP is assumed to handle electrical and protocol recovery, while the wrapper owns format adaptation and status normalization. Reset should define a safe invalid-video state until lock and mode detection are complete.

## Latency, Throughput, and Resource Considerations

The wrapper is mostly adaptation and buffering logic rather than arithmetic, but it must track input pixel rate continuously. Resource use depends on format support and CDC requirements.

## Verification Strategy

- Check raster reconstruction, sync timing, and format metadata against supported HDMI input modes.
- Verify lock, unlock, and reset behavior so downstream video sees a clean validity contract.
- Confirm color format and packing interpretation across several input configurations.

## Integration Notes and Dependencies

This wrapper should be documented with the supported ingress modes and any companion audio or control paths. Integrators should also decide whether downstream modules see raw receiver timing or a normalized video-valid stream.

## Edge Cases, Failure Modes, and Design Risks

- An HDMI mode may appear locked while the internal pixel interpretation is still wrong.
- Recovered-clock to fabric-domain handling bugs often appear only on real hardware.
- If status semantics are vague, downstream blocks may process unstable or invalid video.

## Related Modules In This Domain

- hdmi_tx_wrapper
- sync_separator
- csi2_rx_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the HDMI RX Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
