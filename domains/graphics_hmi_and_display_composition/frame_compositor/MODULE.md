# Frame Compositor

## Overview

Frame Compositor combines several input layers or surfaces into a single output frame according to configured ordering, blending, and visibility rules. It provides the final image-assembly stage for display pipelines.

## Domain Context

A frame compositor is the central assembly stage that combines several graphical layers into one display-ready image. In this domain it is the module that turns independent UI, video, cursor, and effect planes into a coherent final frame.

## Problem Solved

Modern HMIs rarely consist of one monolithic frame source; they combine backgrounds, widgets, text, cursors, and sometimes video or alert overlays. A dedicated compositor makes z-order, alpha policy, and timing explicit instead of scattering them across each layer generator.

## Typical Use Cases

- Combining UI layers and overlays into a single display stream.
- Placing a video or instrument feed behind HUD elements.
- Managing dynamic visibility of alerts, menus, and cursors.
- Providing one deterministic output path for a layered HMI system.

## Interfaces and Signal-Level Behavior

- Inputs are one or more pixel streams or frame-buffer planes plus synchronization and layer-control metadata.
- Outputs provide a composed pixel stream with frame and line timing aligned to the display sink.
- Control interfaces configure z-order, alpha blending, clipping regions, and layer enables.
- Status signals may expose layer_miss, bandwidth_overflow, and frame_done indications.

## Parameters and Configuration Knobs

- Number of supported layers and per-layer pixel format.
- Alpha blend capability and color-depth support.
- Scaling or clipping support per layer.
- Line-buffer or frame-buffer depth for composition timing.

## Internal Architecture and Dataflow

The compositor usually contains layer fetch or stream alignment, z-order arbitration, alpha or key blending, and output-timing control. The critical contract is whether it is stream-time deterministic from prealigned inputs or whether it owns asynchronous frame-buffer fetch and scheduling, because bandwidth and latency expectations differ sharply.

## Clocking, Reset, and Timing Assumptions

The block assumes all layers share a consistent coordinate system or that translation and clipping parameters are provided correctly. Reset clears layer state and should result in a well-defined background or blank output. If not all layers are available for a frame, the missing-layer policy should be explicit.

## Latency, Throughput, and Resource Considerations

Composition can be bandwidth intensive because several layers may need to be read for every displayed pixel. The tradeoff is between richer layering and keeping memory traffic and line buffering within budget. Deterministic output timing matters more than peak arithmetic complexity.

## Verification Strategy

- Compare composed output against a software reference for varied z-order, alpha, and clip configurations.
- Stress layer enable and disable changes at frame boundaries.
- Verify timing and behavior when a layer underflows or misses a fetch deadline.
- Run end-to-end display tests with realistic multi-layer UI scenes.

## Integration Notes and Dependencies

Frame Compositor works with Cursor Overlay, Text Overlay, Sprite Engine, and UI Layer Mixer and typically feeds a display timing or output block. It should align with the memory subsystem on layer-fetch scheduling and with UX software on frame-boundary update semantics.

## Edge Cases, Failure Modes, and Design Risks

- A compositor that is visually plausible but slightly wrong in z-order or alpha semantics can create confusing UI defects.
- Bandwidth starvation can produce intermittent layer dropouts that look like software bugs.
- Frame-boundary semantics for control updates must be explicit or UI changes may tear unpredictably.

## Related Modules In This Domain

- ui_layer_mixer
- cursor_overlay
- text_overlay
- sprite_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frame Compositor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
