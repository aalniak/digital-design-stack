# Compositor

## Overview

The compositor combines several video or graphics layers into one final raster according to z-order, window placement, and blend policy. It is the higher-level assembly stage above primitive alpha blending.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Display pipelines often include several independent layers such as camera video, UI, cursors, and graphics. Combining them correctly requires arbitration of spatial overlap, timing alignment, and per-layer blend semantics. This module provides that structured layer-combination engine.

## Typical Use Cases

- Building a multi-layer display pipeline with video and graphics planes.
- Combining preview, UI, and alert overlays in embedded displays.
- Providing reusable scene assembly before panel output.

## Interfaces and Signal-Level Behavior

- Input side accepts several raster streams or frame-buffer-fed layers with metadata about position and priority.
- Output side emits the composed raster stream and optional coverage or debug status.
- Control side configures layer order, window geometry, alpha or keying rules, and enable masks.

## Parameters and Configuration Knobs

- Number of layers, pixel width, window-coordinate precision, and blend or keying feature set.
- Buffering depth, layer-alignment mode, and supported color formats.
- Runtime control update policy and optional per-layer alpha support.

## Internal Architecture and Dataflow

The block evaluates which layers are active for each destination pixel, determines the topmost visible content according to z-order and window coordinates, and blends or selects among layers as configured. Some implementations draw from frame buffers, while others accept already synchronized streams. The documentation should state whether composition is stream-based, memory-based, or hybrid, because latency and flexibility differ substantially.

## Clocking, Reset, and Timing Assumptions

Layer coordinate systems, alpha conventions, and base raster timing must be common or explicitly converted before composition. Reset should clear layer-enable and alignment state so the first composed frame is well defined.

## Latency, Throughput, and Resource Considerations

Compositors can be moderately expensive because they combine window tests, blending, and possibly several pixel fetch paths. Resource use grows with layer count and feature richness more than with any one arithmetic kernel.

## Verification Strategy

- Compare composed output against a reference scene model with overlapping windows and several alpha values.
- Check z-order, keying, and layer-enable behavior at frame boundaries.
- Verify timing alignment across layers when some sources are delayed or buffered.

## Integration Notes and Dependencies

This module is the final assembly point before display timing or external transport in many systems, so its coordinate and alpha contracts should be shared with UI and graphics producers. Integrators should also document whether layers are frame synchronized or allowed to update independently.

## Edge Cases, Failure Modes, and Design Risks

- A one-pixel coordinate mismatch between layers is very visible and easy to misattribute.
- Unclear z-order or keying policy can make content disappear intermittently.
- Independent-layer update timing can create tearing or mixed-scene frames if not managed deliberately.

## Related Modules In This Domain

- alpha_blender
- osd_engine
- video_mixer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Compositor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
