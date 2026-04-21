# Raw Pixel Unpacker

## Overview

The raw pixel unpacker converts transport-oriented packed raw words into explicit pixel samples, usually before Bayer-aware ISP stages. It is structurally similar to a Bayer unpacker but framed as a generic raw-data unpacking utility across sensor output modes.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Raw image transports optimize link efficiency, not downstream ease of processing. Packed bit fields, lane grouping, and padding must be undone before raw-domain algorithms can operate correctly. This module provides that generic unpacking boundary.

## Typical Use Cases

- Converting packed raw sensor data into one-pixel-per-sample streams.
- Bridging several sensor output packing schemes into a common raw-pixel interface.
- Preparing raw pixels for correction and demosaic stages in ISP pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts packed raw words, line and frame markers, and optional format metadata.
- Output side emits unpacked raw pixel samples with a documented timing and sample order.
- Control side configures pixel depth, packing layout, endianness, and line-end padding behavior.

## Parameters and Configuration Knobs

- Packed word width, pixel width, lane count, and supported format count.
- Endianness, packing order, padding mode, and metadata propagation behavior.
- Runtime format selection and frame-synchronous update policy.

## Internal Architecture and Dataflow

The block slices packed words into pixel-sized fields, tracks any cross-word spill, and outputs a clean raster-ordered raw sample stream. It may preserve auxiliary sideband information about line starts or sensor mode. The contract should define exactly how partial packed words are handled at the end of a line or frame and whether output is tied one-to-one with valid pixels only.

## Clocking, Reset, and Timing Assumptions

The input packing specification must be known exactly, because the block cannot infer word layout safely. Reset should clear any partial assembled state so the next frame begins on a known unpack boundary.

## Latency, Throughput, and Resource Considerations

Unpacking is structurally light but often runs at a high input link rate. Resource use depends mainly on shift or slice logic and any required clock-domain buffering.

## Verification Strategy

- Check unpacked samples against known packed test vectors for each supported format.
- Verify endianness, line-end padding, and reset during partial-word conditions.
- Confirm sideband markers remain aligned to the correct pixel after unpacking.

## Integration Notes and Dependencies

This block is typically at the front of the raw pipeline, and any mismatch here contaminates all later ISP stages. Integrators should preserve the exact upstream packing documentation with the configured module instance.

## Edge Cases, Failure Modes, and Design Risks

- Bit-order and lane-order mistakes can survive several later stages before becoming obvious.
- If partial-word state is not reset correctly, corruption may start only at specific line lengths.
- Runtime format switches without frame synchronization can scramble an entire frame.

## Related Modules In This Domain

- bayer_unpacker
- black_level_correction
- bad_pixel_correction

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Raw Pixel Unpacker module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
