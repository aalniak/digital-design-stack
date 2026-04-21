# Attention Score Unit

## Overview

Attention Score Unit computes query-key similarity scores, typically as batched dot products with optional scaling and masking hooks, for transformer attention workloads. It provides the pre-softmax score matrix generation stage in attention pipelines.

## Domain Context

Attention score computation is the core dot-product stage inside transformer-style models. In an accelerator stack it turns query-key interactions into the raw affinity matrix that later scaling, masking, and softmax stages use to route information across tokens.

## Problem Solved

Transformer models spend significant compute and bandwidth on attention score formation, and the operation has distinct shape, transpose, and masking semantics that do not always fit a generic GEMM wrapper cleanly. A dedicated score unit lets those semantics stay explicit.

## Typical Use Cases

- Computing Q times K transpose score tiles in self-attention and cross-attention.
- Applying scale factors or additive masks before softmax.
- Supporting tiled transformer inference where attention is streamed through local SRAM.
- Exploring attention throughput and memory-bandwidth tradeoffs in hardware research.

## Interfaces and Signal-Level Behavior

- Inputs are query and key tensor tiles plus shape metadata, sequence boundaries, and optional mask fragments.
- Outputs provide score tiles or streamed score rows with valid signaling and optional mask-applied results.
- Control interfaces configure head dimension, scale policy, mask mode, and tile sequencing.
- Status signals often expose tile_done, shape_invalid, and accumulation_overflow conditions.

## Parameters and Configuration Knobs

- Supported head dimension and tile sizes.
- Numeric format for queries, keys, and accumulated scores.
- Optional fused scaling or additive masking support.
- Transpose ownership and memory-layout mode for K input.

## Internal Architecture and Dataflow

The unit often resembles a specialized GEMM with dot-product arrays, accumulation storage, scale insertion, and mask combination positioned for transformer dataflow. The architectural contract should state whether it outputs raw dot products, scaled scores, or already masked scores, because those choices affect numerical stability and the behavior of the downstream softmax stage.

## Clocking, Reset, and Timing Assumptions

The module assumes query and key tensors arrive with consistent head and sequence layout and that masking semantics are defined at the same granularity as the score tile. Reset clears partial tile accumulators. If causal or padding masks are supported, the timing and precedence of those masks relative to scaling should be documented clearly.

## Latency, Throughput, and Resource Considerations

Attention score generation is often memory-bandwidth limited as much as compute limited. Throughput depends on tiling, head dimension, and on-chip buffering. The key performance tradeoff is usually between larger tiles for reuse and smaller tiles that better fit SRAM and control constraints.

## Verification Strategy

- Compare score outputs against a software transformer reference for several head sizes and sequence lengths.
- Stress masking, scaling, and partial-tile boundary cases.
- Verify transpose and layout interpretation of the key tensor explicitly.
- Check accumulator precision and overflow behavior on worst-case large-magnitude inputs.

## Integration Notes and Dependencies

Attention Score Unit usually consumes QKV Projection outputs or preprojected tensors and feeds Softmax plus later value-weighted accumulation stages. It should align with Tensor DMA and memory planners on tile ordering and scratchpad residency.

## Edge Cases, Failure Modes, and Design Risks

- A layout mismatch between queries and keys can silently produce plausible but wrong attention patterns.
- Mask ordering mistakes are easy to miss in small tests but catastrophic in causal models.
- Insufficient accumulator precision can destabilize downstream softmax even when average-case tests pass.

## Related Modules In This Domain

- qkv_projection_helper
- softmax_block
- gemm_engine
- tensor_dma

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Attention Score Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
