# NMS Block

## Overview

NMS Block filters detection candidates by suppressing lower-scored boxes that overlap higher-scored boxes beyond a configured threshold. It provides the candidate-pruning stage needed for many object-detection pipelines.

## Domain Context

Non-maximum suppression is the geometric filtering stage that turns many overlapping detection candidates into a smaller set of final object hypotheses. In an accelerator stack it is a postprocessing primitive that mixes score ranking with box-overlap reasoning rather than dense tensor math.

## Problem Solved

Detector heads often emit many overlapping boxes per object. Without NMS, host software must process and filter large candidate sets, increasing latency and bandwidth. A dedicated block makes IoU thresholding, class-aware filtering, and candidate ordering explicit in hardware.

## Typical Use Cases

- Suppressing redundant detector outputs in object-detection pipelines.
- Reducing host bandwidth by emitting only final or near-final detections.
- Applying class-wise or class-agnostic suppression policies.
- Supporting real-time embedded vision systems where postprocessing latency matters.

## Interfaces and Signal-Level Behavior

- Inputs are candidate boxes, scores, class IDs, and frame or batch boundaries.
- Outputs provide kept candidates, suppression status, and frame-done signaling.
- Control interfaces configure IoU threshold, score threshold, class-aware behavior, and maximum kept detections.
- Status signals may expose candidate_overflow, sort_incomplete, and malformed-box conditions.

## Parameters and Configuration Knobs

- Maximum candidate count and maximum kept output count.
- Coordinate precision and score precision.
- Class-aware versus class-agnostic suppression mode.
- Sorting or preselection depth before overlap checks.

## Internal Architecture and Dataflow

The block usually contains candidate sorting or partial ranking, IoU computation, suppression-state tracking, and output packing. The key contract is whether inputs must already be score-sorted or whether the block owns that ordering, because suppression quality depends heavily on the selected candidate order.

## Clocking, Reset, and Timing Assumptions

The module assumes box coordinates and score semantics match the detector head that produced them. Reset clears candidate buffers and suppression state. If batched or class-partitioned operation is supported, the boundary between independent suppression domains must be explicit.

## Latency, Throughput, and Resource Considerations

NMS is often control-heavy and candidate-count sensitive rather than MAC-bound. Throughput degrades with many high-score overlapping boxes unless prefiltering or top-k limits are applied. The main tradeoff is between exact suppression quality and bounded runtime or buffer cost.

## Verification Strategy

- Compare retained boxes against a software NMS reference for several thresholds and candidate sets.
- Stress degenerate boxes, identical scores, and heavy-overlap scenes.
- Verify class-aware versus class-agnostic behavior and candidate ordering assumptions.
- Check overflow and early-prune paths to ensure no unexpected good detections are dropped.

## Integration Notes and Dependencies

NMS Block typically follows Detector Postprocessor and may be preceded by Argmax/Top-k or thresholding stages. It should align with host result formatting and with detector export tools on whether boxes are corner-based, center-based, normalized, or absolute.

## Edge Cases, Failure Modes, and Design Risks

- Different candidate ordering can yield materially different final detections even with the same IoU threshold.
- Misinterpreting box coordinate convention makes IoU computation wrong while looking mathematically sound.
- Hard output-count limits can silently drop useful detections in crowded scenes if not surfaced clearly.

## Related Modules In This Domain

- detector_postprocessor
- argmax_topk
- conv2d_engine
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the NMS Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
