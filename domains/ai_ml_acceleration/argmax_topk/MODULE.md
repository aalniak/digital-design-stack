# Argmax/Top-k

## Overview

Argmax/Top-k selects the maximum-valued element or the k highest-valued elements from a vector or tensor slice, optionally returning both values and indices. It provides ranking and selection functionality for inference outputs and intermediate candidate pruning.

## Domain Context

Argmax and top-k selection are output-reduction utilities used at the edges of classification, detection, and retrieval pipelines. In an accelerator stack they often live near the postprocessing boundary, where tensors are turned into decisions, candidates, or beam-search seeds.

## Problem Solved

Many networks end in large score vectors that must be reduced to a few actionable candidates. A dedicated selection block avoids pushing high-volume raw scores back to software when only the best classes, anchors, or tokens are needed.

## Typical Use Cases

- Selecting the predicted class from a classifier output vector.
- Producing top-k candidate scores for beam search or retrieval systems.
- Reducing detector-head class scores before later NMS or box filtering.
- Supporting hardware-side pruning of large softmax or logits tensors.

## Interfaces and Signal-Level Behavior

- Inputs are score vectors or streamed tensor slices plus boundary markers indicating the reduction domain.
- Outputs provide selected indices, selected values, and valid or done signaling.
- Control interfaces configure k value, tie-breaking policy, sort order, and whether values, indices, or both are emitted.
- Status signals often expose slice_done, overflow, and invalid_k or malformed-boundary conditions.

## Parameters and Configuration Knobs

- Maximum supported k and slice width.
- Value precision and index width.
- Streaming versus block-buffered selection mode.
- Stable versus unspecified tie-breaking policy.

## Internal Architecture and Dataflow

The module usually contains a comparator tree, running top-k register bank, or partial-sort network depending on throughput goals. The contract should define exactly over what domain the reduction occurs and whether indices are local to a slice, channel, or global tensor coordinate, because that choice affects every downstream consumer.

## Clocking, Reset, and Timing Assumptions

The block assumes slice boundaries are explicit and that all scores in one reduction domain arrive before selection is finalized. Reset clears candidate state. If NaN or invalid numeric values are possible in floating or mixed-precision modes, their treatment should be documented rather than left implicit.

## Latency, Throughput, and Resource Considerations

Selection cost grows with k and vector width but is still modest compared with dense compute blocks. Throughput often depends more on how slices are framed than on comparison arithmetic. The important tradeoff is whether to emit exact sorted top-k at line rate or a lighter-weight partial ranking that software finishes later.

## Verification Strategy

- Compare selected values and indices against a software top-k reference across varied k and tensor widths.
- Stress equal-value ties, negative scores, and boundary handling between slices.
- Verify index semantics, especially for flattened versus structured tensor coordinates.
- Check backpressure behavior so no candidate is dropped when output stalls near slice completion.

## Integration Notes and Dependencies

Argmax/Top-k commonly follows Softmax, Detector Postprocessor, or GEMM-based classifier heads. It should align with NMS and host-facing result formats on index numbering, sorting expectations, and score precision.

## Edge Cases, Failure Modes, and Design Risks

- Ambiguous index semantics can make selected candidates point at the wrong class or anchor even when scores are correct.
- Tie-breaking that changes with hardware timing can hurt reproducibility and testing.
- Using top-k too early in the pipeline may prune candidates needed for later joint reasoning.

## Related Modules In This Domain

- softmax_block
- detector_postprocessor
- nms_block
- gemm_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Argmax/Top-k module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
