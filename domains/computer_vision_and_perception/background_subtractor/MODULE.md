# Background Subtractor

## Overview

The background subtractor models the static or slowly varying scene and identifies pixels or regions that differ sufficiently to be considered foreground motion or change. It is a standard front-end detector for surveillance, occupancy, and motion-triggered analytics.

## Domain Context

Computer-vision and perception modules convert images and intermediate features into structured scene information such as edges, objects, motion, and geometry. In this domain the key documentation topics are coordinate conventions, feature representations, confidence semantics, latency through frame and track state, and how each block expects upstream preprocessing to have normalized the visual input.

## Problem Solved

Many perception tasks care only about scene changes, but comparing every frame to nothing in particular makes ordinary lighting drift or camera noise look like motion. This module provides the reusable background model and subtraction logic needed to isolate true foreground activity.

## Typical Use Cases

- Detecting moving objects in mostly static camera scenes.
- Generating foreground masks for occupancy, tracking, or trigger logic.
- Providing reusable change detection in embedded vision systems.

## Interfaces and Signal-Level Behavior

- Input side accepts one or more image channels and frame timing.
- Output side emits a foreground mask, optional confidence, and possibly model-update status.
- Control side configures learning rate, thresholding, and background-model mode.

## Parameters and Configuration Knobs

- Pixel format, model precision, learning-rate representation, and threshold width.
- Single-background versus multi-model mode, shadow or illumination handling, and output mask format.
- Per-pixel versus global adaptation settings and reset behavior.

## Internal Architecture and Dataflow

The block maintains a background estimate per pixel or region and compares the current frame against that estimate to decide whether a location is foreground. It may update the model continuously, selectively, or with motion-aware gating. The contract should define whether the output is a hard binary mask, a soft foreground score, or both, and when the model is frozen or updated.

## Clocking, Reset, and Timing Assumptions

Background subtraction assumes a mostly stationary camera or a documented form of compensation for motion. Reset should initialize or invalidate the model explicitly so early-frame outputs are interpretable.

## Latency, Throughput, and Resource Considerations

This stage is memory-heavy because it stores model state over the frame and updates it every image. Throughput must match full frame rate, while resource cost depends on model complexity and frame size.

## Verification Strategy

- Compare foreground masks against a software reference on static-scene sequences with controlled motion.
- Check model warm-up, reset behavior, and illumination-change sensitivity.
- Verify that model-update gating behaves as documented during persistent foreground presence.

## Integration Notes and Dependencies

This block usually follows basic image normalization and precedes blob detection or tracking, so the meaning of its mask output should be documented for those consumers. Integrators should also state whether camera motion is possible and how that affects deployment.

## Edge Cases, Failure Modes, and Design Risks

- A model that adapts too quickly can absorb slow-moving objects into the background.
- A model that adapts too slowly may trigger constantly on illumination drift.
- If reset or startup behavior is vague, early frames may produce misleading detections.

## Related Modules In This Domain

- blob_detector
- connected_components_labeler
- optical_flow_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Background Subtractor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
