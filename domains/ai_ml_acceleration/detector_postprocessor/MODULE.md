# Detector Postprocessor

## Overview

Detector Postprocessor transforms detection-head outputs into scored candidate boxes, classes, and associated attributes ready for ranking or suppression. It provides the structured decode stage between raw model tensors and final detection results.

## Domain Context

Detector postprocessing is the bridge from raw detection-head tensors to usable object hypotheses. In an accelerator stack it is where anchor decoding, score thresholding, coordinate transforms, and class interpretation become explicit before NMS or host consumption.

## Problem Solved

Detection networks rarely emit boxes and classes in final usable form; they usually output encoded offsets, anchor-relative values, or per-class logits that require deterministic decode logic. A dedicated postprocessor makes those decode rules hardware-visible and testable.

## Typical Use Cases

- Decoding anchor-based detector outputs into absolute boxes and class scores.
- Thresholding and pruning raw detector head results before NMS.
- Supporting SSD, YOLO-like, or custom detection heads with explicit decode rules.
- Reducing host-side postprocessing load in edge-inference systems.

## Interfaces and Signal-Level Behavior

- Inputs are detector-head tensors, anchor or grid metadata, and shape parameters describing the prediction layout.
- Outputs provide candidate boxes, class IDs or score vectors, and validity or threshold-pass flags.
- Control interfaces configure decode formula, confidence threshold, coordinate scaling, and class-count interpretation.
- Status signals may expose decode_done, candidate_overflow, and malformed-shape conditions.

## Parameters and Configuration Knobs

- Maximum number of anchors or candidates per tile.
- Box coordinate precision and score precision.
- Supported anchor-based or anchor-free decode modes.
- On-chip candidate buffer depth before NMS or host handoff.

## Internal Architecture and Dataflow

The postprocessor generally contains score activation or selection hooks, anchor or grid decode arithmetic, threshold filtering, and candidate packing. The architectural contract should define the exact head format it expects, because different detectors encode widths, heights, centers, and classes in materially different ways.

## Clocking, Reset, and Timing Assumptions

The module assumes the upstream model head and offline compiler agree on tensor layout, anchor ordering, and score activation convention. Reset clears candidate buffers and decode context. If thresholds are programmable at runtime, their activation boundary should be explicit to avoid mixing policies within one image batch.

## Latency, Throughput, and Resource Considerations

Compute cost is moderate, but candidate explosion can stress buffers and output bandwidth. Throughput depends on how aggressively low-score candidates are pruned before full box decode. The practical tradeoff is between preserving recall and avoiding overwhelming NMS or host software with low-value candidates.

## Verification Strategy

- Compare decoded candidate boxes and scores against a software postprocessing reference for each supported head format.
- Stress threshold boundaries, anchor ordering, and box-clamp behavior.
- Verify candidate packing and overflow handling on images with many detections.
- Check score interpretation, such as sigmoid or softmax assumptions, against model-export conventions.

## Integration Notes and Dependencies

Detector Postprocessor typically consumes Conv2D or GEMM-produced head tensors and feeds NMS Block or Argmax/Top-k style ranking logic. It must align tightly with model export tools, because a head-format mismatch produces downstream errors that are hard to localize back to this boundary.

## Edge Cases, Failure Modes, and Design Risks

- Using the wrong decode formula for a head format can yield plausible but physically wrong boxes.
- Threshold or activation mismatches may silently crush recall or flood NMS with junk candidates.
- If class and box tensors are paired incorrectly across layout transformations, detections can point to the wrong class with the right geometry.

## Related Modules In This Domain

- nms_block
- argmax_topk
- conv2d_engine
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Detector Postprocessor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
