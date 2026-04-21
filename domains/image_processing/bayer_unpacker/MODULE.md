# Bayer Unpacker

## Overview

The Bayer unpacker converts packed raw sensor words into an explicit raster pixel stream with the correct Bayer pattern context preserved. It is one of the earliest stages in a raw image pipeline.

## Domain Context

Image-processing modules transform raw pixel streams into corrected, measurable, and visually useful image data. In this domain the key documentation topics are pixel format assumptions, line and frame timing, boundary handling, color-space conventions, and how statistics or geometric operations interact with streaming image memory.

## Problem Solved

Sensors often emit packed bit fields or lane-grouped words that are efficient for transport but inconvenient for image processing. Downstream stages need a clean pixel stream with correct sample ordering and color-site interpretation. This module performs that unpacking step consistently.

## Typical Use Cases

- Preparing raw sensor output for black-level correction and bad-pixel correction.
- Converting packed transport words into one-pixel-at-a-time ISP-friendly streams.
- Providing a reusable bridge from sensor link formatting into image-processing infrastructure.

## Interfaces and Signal-Level Behavior

- Input side accepts packed sensor words, line markers, frame markers, and optional lane-valid metadata.
- Output side emits unpacked raw pixel samples with raster timing and Bayer-site context.
- Control side configures pixel depth, packing format, Bayer order, and end-of-line padding behavior.

## Parameters and Configuration Knobs

- Packed word width, pixel bit depth, lane count, and Bayer pattern order.
- Endianness, sample packing order, and optional metadata propagation.
- Support for several sensor output formats or transport modes.

## Internal Architecture and Dataflow

The block parses incoming packed words, extracts each pixel sample in the correct order, and reconstructs the raster stream expected by later ISP stages. It also tracks line and frame position so the correct Bayer color site is associated with each output sample. The contract should define whether partial words at line ends are supported and how padding is handled.

## Clocking, Reset, and Timing Assumptions

The incoming packing convention and Bayer order must be known exactly, because an unpacker cannot infer either safely from the bitstream. Reset should clear any partial-word state so the next frame starts aligned to the correct pixel boundary.

## Latency, Throughput, and Resource Considerations

Unpacking is structurally simple but often runs at high sensor data rates. Resource use depends on packing complexity, lane count, and buffering needed to cross into the fabric-side clock domain.

## Verification Strategy

- Check pixel extraction order, bit slicing, and Bayer-site tagging against known packed test patterns.
- Verify line-end padding and partial-word behavior.
- Confirm reset and frame-boundary handling do not leak partial packed data into the next line or frame.

## Integration Notes and Dependencies

This block sits at the very front of the image pipeline, so mistakes here contaminate every later stage. Integrators should preserve the sensor packing specification and Bayer pattern definition directly with the module configuration.

## Edge Cases, Failure Modes, and Design Risks

- A bit-order error can create subtle image corruption that may only be noticed after demosaicing.
- Wrong Bayer order propagates into color artifacts throughout the pipeline.
- Partial-word handling at line ends can shift every subsequent pixel if not reset correctly.

## Related Modules In This Domain

- black_level_correction
- bad_pixel_correction
- ae_awb_af_statistics

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bayer Unpacker module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
