# Panel Timing Controller

## Overview

The panel timing controller shapes raster timing and panel-specific control signals required by an embedded display or timing-sensitive output interface. It is the final display-synchronization stage in many panel-connected systems.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Panels often require more than generic video sync markers; they need tightly defined blanking, enable, and control timing. This module provides that panel-specific timing coordination so the rest of the display pipeline can remain in a cleaner video domain.

## Typical Use Cases

- Driving LCD or similar embedded panels with precise timing requirements.
- Adapting internal video raster timing to a panel-specific interface contract.
- Providing reusable panel-control logic in embedded display systems.

## Interfaces and Signal-Level Behavior

- Video side accepts active raster pixels and timing metadata from internal display logic.
- Panel side emits enable, sync, blanking, and optional gating signals required by the target panel interface.
- Control side configures active region, porches, sync widths, and panel mode selection.

## Parameters and Configuration Knobs

- Horizontal and vertical timing values, polarity settings, and output control-signal set.
- Pixel format or packing assumptions if the panel interface bundles data formatting.
- Runtime mode-switch support and synchronization policy.

## Internal Architecture and Dataflow

The block counts pixel and line positions within a frame, generates the panel-specific timing signals from the configured geometry, and aligns active video data to that schedule. It may also gate blanking or drive data-enable signals needed by a parallel panel path. The contract should distinguish clearly between generic video timing and panel-specific control outputs.

## Clocking, Reset, and Timing Assumptions

The downstream panel timing requirements must be known exactly, including polarity and blanking rules. Reset should establish a safe disabled or blank state before valid timing starts.

## Latency, Throughput, and Resource Considerations

This is mostly timing-generation logic with very low arithmetic cost, but it sits on the critical correctness path for visible output. Resource use is small and dominated by counters and control logic.

## Verification Strategy

- Compare generated timing against the configured panel-mode specification.
- Check polarity, blanking, and active-video alignment.
- Verify mode switches and resets occur at safe frame boundaries.

## Integration Notes and Dependencies

This controller is often the last logic stage before a panel interface or TX wrapper, so its timing contract should be documented together with the chosen panel mode. Integrators should also note whether the pixel data path or only control signals pass through it.

## Edge Cases, Failure Modes, and Design Risks

- A one-count error in porch or active region timing can make a panel appear unstable or misaligned.
- Polarity mismatches are easy to overlook and may vary across panel revisions.
- Unsafe runtime mode changes can leave the panel in a confused state even if the raster path is otherwise correct.

## Related Modules In This Domain

- video_timing_controller
- dsi_tx_wrapper
- hdmi_tx_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Panel Timing Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
