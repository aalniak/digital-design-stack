# Test Pattern Generator

## Overview

The test pattern generator synthesizes deterministic video images such as color bars, ramps, grids, and alignment markers for bring-up, validation, and calibration. It is one of the most useful debug stages in any video system.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Debugging a video pipeline is much easier when the input is known and controllable, but external pattern sources add cost and setup friction. This module provides the internal pattern source that many integration and validation flows depend on.

## Typical Use Cases

- Bringing up display pipelines without a live camera or frame source.
- Validating format conversion, scaling, and timing with known patterns.
- Providing calibration or alignment imagery for system test.

## Interfaces and Signal-Level Behavior

- Timing side accepts a raster reference or internal timing configuration from a sync generator.
- Output side emits generated pixel values with full raster timing.
- Control side selects pattern type, colors, geometry, and optional animated or moving markers.

## Parameters and Configuration Knobs

- Pixel format, pattern set, color depth, and coordinate precision.
- Support for bars, ramps, checkerboards, grids, or custom overlays.
- Runtime pattern switching and timing-source selection.

## Internal Architecture and Dataflow

The generator computes pixel values from the current raster coordinates and the selected pattern definition, often using simple combinational formulas for bars, ramps, and grids. More advanced variants may incorporate animated counters or moving markers. The documentation should define the exact coordinate basis and color coding for each named pattern so tests are reproducible.

## Clocking, Reset, and Timing Assumptions

Generated patterns are meaningful only with a documented pixel format and timing source. Reset should establish a known starting frame phase, especially for animated patterns.

## Latency, Throughput, and Resource Considerations

Pattern generation is lightweight and typically supports one pixel per cycle with small logic cost. The main value is observability and deterministic behavior, not heavy processing.

## Verification Strategy

- Compare emitted patterns against expected coordinate-driven reference images.
- Check color coding, pattern switching, and animated-pattern phase behavior.
- Verify timing alignment when the generator is driven by an external sync source versus internal timing.

## Integration Notes and Dependencies

This block often sits near sync generators and output wrappers and should be easy to substitute for live video sources. Integrators should document how pattern IDs map to human-visible content for bring-up teams.

## Edge Cases, Failure Modes, and Design Risks

- If pattern definitions are not documented clearly, test expectations will drift across teams.
- Animated patterns without a defined reset phase can make regression images nondeterministic.
- Color-format assumptions may make a correct pattern look wrong when viewed through another format stage.

## Related Modules In This Domain

- sync_generator
- video_timing_controller
- video_scaler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Test Pattern Generator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
