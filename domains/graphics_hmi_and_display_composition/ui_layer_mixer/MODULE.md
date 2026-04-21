# UI Layer Mixer

## Overview

UI Layer Mixer merges UI-oriented layers or widget surfaces according to layout and blending policy optimized for human-machine interfaces. It provides intermediate composition focused on interface elements rather than arbitrary video planes.

## Domain Context

A UI layer mixer is a slightly more policy-oriented composition block focused on interface layers rather than raw pixel planes. In this domain it typically manages widget, panel, and status-surface integration before or within the final frame composition path.

## Problem Solved

UI layers often need compositing semantics that differ from full frame composition, such as panel-local blending, priority alerts, or fixed chrome regions. A dedicated mixer keeps that policy concentrated and reusable.

## Typical Use Cases

- Combining dashboard widgets and status panels into one UI plane.
- Managing alert overlays and menu layers before final display composition.
- Providing a reusable mixer for HMI software that draws several independent surfaces.
- Separating UI policy composition from lower-level video or background composition.

## Interfaces and Signal-Level Behavior

- Inputs are UI surface streams or tile updates plus layout metadata and blend controls.
- Outputs provide a mixed UI layer or intermediate composed surface.
- Control interfaces configure per-layer priority, visibility, clipping, and blend behavior.
- Status signals may expose surface_overrun, invalid_region, and mix_done indications.

## Parameters and Configuration Knobs

- Supported number of UI surfaces.
- Per-surface pixel format and alpha mode.
- Region-based clipping and coordinate range.
- Line-buffer or tile-buffer depth.

## Internal Architecture and Dataflow

The mixer usually contains region-aware blending, layer-order policy, and buffering tailored to UI surfaces rather than generic full-screen frame fetch. The key contract is whether it outputs a full-screen intermediate surface or a stream of UI deltas, because system memory bandwidth and update policy depend on that distinction.

## Clocking, Reset, and Timing Assumptions

The module assumes UI surfaces are aligned to the same pixel clock or are buffered enough to be composed deterministically. Reset should result in a blank or base UI state according to product policy. If region updates are partial, the persistence and invalidation rules should be explicit.

## Latency, Throughput, and Resource Considerations

Compared with a full compositor, a UI mixer often trades some generality for lower bandwidth on partial updates. The key tradeoff is between flexible region-based updates and the complexity of tracking dirty regions and persistent surface content.

## Verification Strategy

- Compare mixed surfaces against a UI composition reference for several layout cases.
- Stress overlapping regions, partial updates, and rapid visibility changes.
- Check alert-priority or reserved-region behavior where applicable.
- Verify whether frame and delta update modes behave according to the documented contract.

## Integration Notes and Dependencies

UI Layer Mixer commonly feeds Frame Compositor and works with Text Overlay, Icon Cache, and Touch Bridge logic. It should align with the GUI software architecture on whether UI is updated as full frames or partial regions.

## Edge Cases, Failure Modes, and Design Risks

- Mixing full-frame and delta-based assumptions can produce stale or torn UI regions.
- Priority rules for alerts and menus must be explicit or critical interface elements may be obscured.
- A UI-focused mixer reused for general video composition may reveal untested semantic gaps.

## Related Modules In This Domain

- frame_compositor
- text_overlay
- icon_cache
- touch_bridge

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the UI Layer Mixer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
