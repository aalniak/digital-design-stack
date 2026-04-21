# Frame Rate Converter

## Overview

The frame rate converter changes video cadence between source and destination frame rates while attempting to preserve acceptable temporal behavior. It is a temporal adaptation stage rather than a simple line or pixel-rate conversion block.

## Domain Context

Video-processing and display modules move image content through time-aware raster pipelines, memory-backed frame stages, and external display or camera interfaces. In this domain the critical documentation topics are frame and line timing, pixel packing, latency through buffering, color-format assumptions, and how synchronization is preserved across scaling, compositing, and transport wrappers.

## Problem Solved

Source and destination video systems often run at different frame rates, and simply dropping or duplicating frames can create judder or mismatch downstream timing assumptions. This module provides a structured cadence-conversion stage with explicit temporal policy.

## Typical Use Cases

- Matching camera or playback cadence to a display refresh rate.
- Converting captured video to a target processing or output frame rate.
- Serving as a reusable temporal adaptation block in mixed-rate video systems.

## Interfaces and Signal-Level Behavior

- Input side accepts timed frames or fields with frame markers and cadence metadata.
- Output side emits frames at the destination cadence and reports drop, repeat, or interpolation status.
- Control side configures source and destination rates, temporal policy, and buffer-management behavior.

## Parameters and Configuration Knobs

- Input and output frame-rate ratio, buffering depth, and temporal conversion mode.
- Frame interpolation or repeat policy, latency budget, and underflow or overflow handling.
- Runtime mode switching and whether timestamps are propagated or regenerated.

## Internal Architecture and Dataflow

Simple implementations select which source frames to repeat or drop according to a cadence schedule, while richer designs buffer neighboring frames and interpolate motion or intensity over time. The contract should be honest about which class of behavior is implemented and how much latency is introduced. It should also state whether the output cadence is strictly regular even when source cadence is irregular.

## Clocking, Reset, and Timing Assumptions

Frame boundaries and timing metadata from upstream must be trustworthy, because temporal adaptation depends on them. Reset should define how the first few output frames are generated before enough source history exists.

## Latency, Throughput, and Resource Considerations

Frame-rate conversion often requires at least frame-level buffering and can be memory heavy. Computational cost ranges from low for repeat-drop modes to substantial for interpolation modes.

## Verification Strategy

- Compare output cadence and temporal behavior against a reference scheduler or interpolation model.
- Check startup, mode switching, and irregular source cadence handling.
- Verify timestamp or status propagation so downstream systems can identify repeated or synthesized frames.

## Integration Notes and Dependencies

This block usually sits between captured or generated video and a display or encoder. Integrators should document temporal latency and whether the output is safe for analytics that assume every frame is original source content.

## Edge Cases, Failure Modes, and Design Risks

- A cadence schedule bug can create subtle judder that is hard to attribute from static tests.
- Interpolated-frame quality may be unacceptable for the intended content even if timing is correct.
- If repeated or synthetic frames are not identified, downstream analytics may overcount or misinterpret motion.

## Related Modules In This Domain

- deinterlacer
- video_scaler
- frame_buffer_reader

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Frame Rate Converter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
