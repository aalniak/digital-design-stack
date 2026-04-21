# Cursor Overlay

## Overview

Cursor Overlay renders a pointer or focus indicator on top of a display stream with low latency and minimal full-frame redraw cost. It provides a dedicated overlay path for interactive pointing or selection feedback.

## Domain Context

A cursor overlay is a special low-latency sprite-like layer optimized for pointer or focus indication. In this domain it exists because cursor responsiveness and simple alpha or keying behavior often deserve a dedicated fast path.

## Problem Solved

Cursor movement should feel immediate and should not require full UI recomposition or frame redraw. A dedicated cursor path keeps latency low and simplifies frequent position updates.

## Typical Use Cases

- Displaying a mouse-like cursor or focus reticle over an embedded UI.
- Providing responsive pointing feedback on operator displays.
- Highlighting current selection in a dashboard or control panel.
- Supporting touch or remote-control interfaces with explicit pointer feedback.

## Interfaces and Signal-Level Behavior

- Inputs include cursor position, image or shape selection, enable, and optional hotspot metadata.
- Outputs provide overlay pixels or direct injection into the display stream.
- Control interfaces configure transparency, size, and frame-boundary update behavior.
- Status signals may expose out_of_range_position and cursor_active indications.

## Parameters and Configuration Knobs

- Cursor size and pixel format.
- Transparency-key or alpha support.
- Hotspot coordinate support.
- Update-rate and frame-boundary synchronization options.

## Internal Architecture and Dataflow

The overlay usually contains a small image store or fetch path, coordinate compare logic, and pixel substitution or blend control. The key contract is whether position updates are applied immediately or only at frame boundaries, because responsiveness and tearing behavior depend on that policy.

## Clocking, Reset, and Timing Assumptions

The module assumes the display timing and coordinate system are known and stable. Reset should disable the cursor or place it at a documented default location. If the cursor image is externally supplied, its format and update protocol should be explicit.

## Latency, Throughput, and Resource Considerations

Cursor overlays are small and low area, but they sit on timing-critical display paths. The tradeoff is between immediate update responsiveness and avoiding mid-frame visual tearing. Bandwidth cost is usually minimal compared with full-layer composition.

## Verification Strategy

- Compare cursor rendering against a software overlay reference across several positions and image patterns.
- Stress rapid position updates and edge-of-screen behavior.
- Check hotspot alignment and transparency semantics.
- Verify frame-boundary versus immediate-update behavior matches the documented contract.

## Integration Notes and Dependencies

Cursor Overlay commonly feeds Frame Compositor directly or via UI Layer Mixer and may interact with Touch Bridge for pointer generation. It should align with HMI software on coordinate origin and update timing.

## Edge Cases, Failure Modes, and Design Risks

- Applying updates at the wrong point in the frame can create distracting cursor tearing.
- Hotspot misdefinition causes persistent pointing offset that feels like a software problem.
- If transparency rules are vague, the cursor can obscure or visually corrupt critical UI content.

## Related Modules In This Domain

- frame_compositor
- ui_layer_mixer
- touch_bridge
- sprite_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Cursor Overlay module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
