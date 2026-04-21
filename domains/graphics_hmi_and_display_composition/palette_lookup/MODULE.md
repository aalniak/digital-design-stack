# Palette Lookup

## Overview

Palette Lookup converts indexed color values into expanded pixel colors using a programmable or fixed palette table. It provides a color-expansion primitive for indexed display assets and overlays.

## Domain Context

Palette lookup maps compact indexed pixel values into actual display colors, reducing memory footprint for sprites, fonts, icons, and some low-color UI assets. In this domain it is the color-expansion stage for indexed graphics.

## Problem Solved

Many embedded graphics assets are stored efficiently as palette indices rather than full-color pixels. A dedicated lookup block standardizes how those indices become real colors and how palette changes affect active content.

## Typical Use Cases

- Expanding indexed sprites and icons into display colors.
- Rendering low-memory UI themes and font assets.
- Supporting dynamic color-theme changes via palette updates.
- Providing color indirection for alert-state or mode-dependent graphics.

## Interfaces and Signal-Level Behavior

- Inputs are indexed pixel values plus valid timing and optional asset or layer metadata.
- Outputs provide expanded color pixels with aligned valid signaling.
- Control interfaces configure palette contents, active bank selection, and update timing.
- Status signals may expose index_out_of_range and palette_bank_invalid conditions.

## Parameters and Configuration Knobs

- Index width and palette depth.
- Output color format and precision.
- Single versus dual-bank palette update support.
- Optional transparency index support.

## Internal Architecture and Dataflow

The block typically contains one or more small color tables and address-based expansion logic. The key contract is whether palette updates take effect immediately or on a safe boundary such as a frame edge, because visual stability depends on that timing.

## Clocking, Reset, and Timing Assumptions

The module assumes indexed assets and palette definitions agree on index meaning and transparency policy. Reset should load a documented default palette or mark output invalid until programmed. If several layers share one palette resource, the ownership model should be explicit.

## Latency, Throughput, and Resource Considerations

Palette lookup is low cost and can usually run at pixel rate. The main tradeoff is between simple single-bank palettes and double-buffered or multi-palette schemes that allow dynamic color changes without visible artifacts.

## Verification Strategy

- Verify color expansion against reference palette tables and indexed assets.
- Stress palette updates during active display and check documented activation timing.
- Check transparency-index handling and out-of-range index behavior.
- Run integration tests with sprites, icons, and text assets using palette indices.

## Integration Notes and Dependencies

Palette Lookup commonly sits under Sprite Engine, Icon Cache, Font ROM Renderer, and Text Overlay. It should align with asset-generation tooling so index assignments remain stable across the UI pipeline.

## Edge Cases, Failure Modes, and Design Risks

- Mid-frame palette changes can produce obvious but hard-to-debug flicker if not controlled.
- Index mismatches between assets and palette tables corrupt colors globally.
- Shared palette resources can create accidental cross-layer coupling unless ownership is explicit.

## Related Modules In This Domain

- sprite_engine
- font_rom_renderer
- text_overlay
- icon_cache

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Palette Lookup module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
