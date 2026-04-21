# Text Overlay

## Overview

Text Overlay renders glyphs and text strings into an output layer or directly into a composed display stream. It provides hardware-assisted textual annotation for HMIs, instrumentation, and display overlays.

## Domain Context

Text overlay logic turns characters, labels, and annotations into rasterized pixels on top of a display scene. In this domain it is the practical bridge from human-readable UI data to visible display elements.

## Problem Solved

Text is pervasive in interfaces, but software-rendering it into full frames can consume bandwidth and complicate frequent updates. A dedicated text overlay block centralizes glyph lookup, layout assumptions, and blending policy.

## Typical Use Cases

- Displaying labels, units, and status text on dashboards.
- Rendering debug or measurement annotations over video or graphics.
- Providing low-overhead text for embedded displays with limited CPU time.
- Supporting multilingual or symbol-rich overlays within the supported font set.

## Interfaces and Signal-Level Behavior

- Inputs include character codes, position metadata, style controls, and string or text-buffer boundaries.
- Outputs provide rasterized text pixels or a text overlay layer.
- Control interfaces configure font selection, foreground and background style, clipping, and update timing.
- Status signals may expose unsupported_glyph, text_overrun, and render_active indications.

## Parameters and Configuration Knobs

- Character code width and supported font count.
- Maximum text region size and glyph dimensions.
- Color and transparency mode.
- Immediate versus frame-boundary text update policy.

## Internal Architecture and Dataflow

The block generally contains glyph fetch, text layout stepping, clipping, and pixel generation or blending. The architectural contract should define whether it performs simple monospaced character placement, richer proportional layout, or just glyph stamping, because downstream UI software depends on that capability boundary.

## Clocking, Reset, and Timing Assumptions

The module assumes text buffers and font resources are coherent and that character encoding matches the configured font set. Reset clears active overlay state or leaves a blank text layer. If unsupported characters are possible, fallback behavior should be explicit.

## Latency, Throughput, and Resource Considerations

Text rendering is usually limited by glyph fetch and pixel emission rather than heavy arithmetic. The main tradeoff is between richer layout features and minimal deterministic rendering cost. Frequent small text updates often matter more than peak full-screen throughput.

## Verification Strategy

- Compare rasterized output against a software reference for representative fonts and strings.
- Stress clipping, line boundaries, and unsupported glyph handling.
- Verify update timing and persistence of previous text regions.
- Check color and transparency behavior in composed scenes.

## Integration Notes and Dependencies

Text Overlay often works with Font ROM Renderer, Frame Compositor, and UI Layer Mixer. It should align with UI software on text encoding, coordinate origin, and whether layout is precomputed or performed in hardware.

## Edge Cases, Failure Modes, and Design Risks

- Layout assumptions that are too implicit can make text appear misaligned or clipped unexpectedly.
- Unsupported-glyph fallback should be visible and deterministic, not silent corruption.
- Partial updates can leave stale text on screen if persistence rules are vague.

## Related Modules In This Domain

- font_rom_renderer
- frame_compositor
- ui_layer_mixer
- palette_lookup

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Text Overlay module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
