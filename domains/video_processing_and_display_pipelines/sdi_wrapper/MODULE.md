# SDI Wrapper

## Overview

The SDI wrapper adapts serial digital interface video transport blocks into the internal raster and status conventions used by the repository. It provides a stable seam between broadcast-style transport and ordinary video processing logic.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

SDI links carry timing and ancillary semantics that are useful at the transport boundary but burdensome elsewhere in the pipeline. This wrapper normalizes that behavior so downstream blocks can work with a simpler video-stream interface.

## Typical Use Cases

- Bringing SDI sources into a video-processing system or driving SDI outputs from one.
- Abstracting vendor SDI IP behind a stable internal interface.
- Providing reusable broadcast-style transport adaptation in FPGA video systems.

## Interfaces and Signal-Level Behavior

- Transport side connects to SDI receiver or transmitter cores and associated status signals.
- Video side emits or consumes raster streams with timing and format metadata.
- Control side configures mode interpretation, reset handling, and link or lock status adaptation.

## Parameters and Configuration Knobs

- Supported SDI mode set, pixel packing style, buffering depth, and TX versus RX wrapper flavor.
- Clock-domain adaptation, ancillary-data exposure, and runtime mode-switch limits.
- Status-report detail and color-format support.

## Internal Architecture and Dataflow

The wrapper translates between SDI-core semantics and the repository's raster video contracts, handling timing normalization, packing adaptation, and status propagation. Depending on direction, it may also manage blanking or validity gating around link lock. The contract should clarify which broadcast-specific metadata is surfaced and which is intentionally hidden.

## Clocking, Reset, and Timing Assumptions

The lower SDI core is assumed to manage the transport protocol and electrical specifics, while the wrapper manages raster adaptation. Reset should define when the video side may trust incoming or outgoing timing.

## Latency, Throughput, and Resource Considerations

The wrapper is dominated by buffering and adaptation rather than arithmetic and must sustain the relevant SDI pixel rate continuously. Resource use is moderate and depends on supported mode breadth.

## Verification Strategy

- Check raster mapping, timing, and format interpretation for supported SDI modes.
- Verify lock or status propagation and reset behavior.
- Confirm ancillary-data exposure or omission matches the documented contract.

## Integration Notes and Dependencies

This wrapper belongs at the transport boundary, so supported broadcast modes and metadata scope should be documented alongside it. Integrators should also state whether separate audio or ancillary paths exist.

## Edge Cases, Failure Modes, and Design Risks

- If format interpretation is wrong, the transport may appear healthy while the video content is incorrect.
- Unclear status semantics can make downstream blocks process unstable input.
- Mode-switch handling may fail only on real equipment if boundaries are not explicit.

## Related Modules In This Domain

- hdmi_rx_wrapper
- hdmi_tx_wrapper
- sync_separator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SDI Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
