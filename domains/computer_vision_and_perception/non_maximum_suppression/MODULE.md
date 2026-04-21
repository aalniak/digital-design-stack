# Non-Maximum Suppression

## Overview

The non-maximum suppression module filters overlapping or competing detections so only the strongest representatives of the same object hypothesis remain. It is a standard detection postprocessing stage.

## Domain Context

Computer-vision and perception modules convert images and intermediate features into structured scene information such as edges, objects, motion, and geometry. In this domain the key documentation topics are coordinate conventions, feature representations, confidence semantics, latency through frame and track state, and how each block expects upstream preprocessing to have normalized the visual input.

## Problem Solved

Raw detectors often emit many nearby or overlapping candidates for one object. Without suppression, tracking and counting become unstable. This module centralizes that pruning logic so downstream stages see a cleaner detection set.

## Typical Use Cases

- Pruning overlapping detection boxes after learned or heuristic detectors.
- Reducing duplicate peaks from saliency or feature maps.
- Providing reusable candidate suppression in perception pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts scored detection records with geometry or peak-location metadata.
- Output side emits the retained subset and optional suppression status or counts.
- Control side configures suppression metric, threshold, sorting policy, and class-aware behavior.

## Parameters and Configuration Knobs

- Maximum candidate count, score precision, geometry width, and suppression threshold.
- IoU or distance metric mode, class-aware suppression support, and output count limit.
- Runtime threshold updates and coordinate convention selection.

## Internal Architecture and Dataflow

The module orders candidates by confidence, then iteratively keeps or suppresses later candidates according to overlap or proximity to already selected ones. Depending on the design it may perform class-aware suppression or simpler generic suppression. The contract should define the overlap metric, candidate order, and whether outputs remain sorted by score.

## Clocking, Reset, and Timing Assumptions

Suppression only makes sense when candidate geometry uses a documented common coordinate convention and score semantics. Reset should clear any staged candidate buffers before a new frame begins.

## Latency, Throughput, and Resource Considerations

NMS can be moderately heavy because pairwise overlap checks grow with candidate count. Resource use depends on candidate buffer size and the overlap metric used.

## Verification Strategy

- Compare retained detections against a software NMS reference on several candidate sets.
- Check sorting, class-aware behavior, and threshold edge cases.
- Verify output count limits and reset behavior between frames.

## Integration Notes and Dependencies

This module typically follows box decoding and precedes association or display, so its geometry and score conventions should remain consistent with those consumers. Integrators should also state whether per-class or global suppression is intended.

## Edge Cases, Failure Modes, and Design Risks

- IoU convention differences can alter detection count noticeably while every box still looks plausible.
- Sorting-policy mismatches may make hardware results diverge from software evaluation pipelines.
- If score ties are handled inconsistently, regression comparisons may appear unstable.

## Related Modules In This Domain

- bounding_box_decoder
- multi_object_association
- kalman_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Non-Maximum Suppression module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
