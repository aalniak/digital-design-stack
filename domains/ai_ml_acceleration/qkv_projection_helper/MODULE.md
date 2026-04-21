# QKV Projection Helper

## Overview

QKV Projection Helper organizes the projection of hidden-state tensors into query, key, and value outputs, handling tensor partitioning, output packing, and head-aware metadata around the underlying matrix multiplies. It provides transformer-specific structure around the projection stage before attention score and value mixing.

## Domain Context

QKV projection is the front-end linear transform that turns model hidden states into query, key, and value tensors for attention. In an accelerator stack this helper exists because the three projections are structurally similar but often need coordinated scheduling, packing, and head-wise partitioning rather than being treated as unrelated GEMMs.

## Problem Solved

Compilers can lower Q, K, and V projections to generic GEMMs, but doing so naively can waste bandwidth and obscure head partitioning semantics. A dedicated helper makes the shared input reuse and output reshaping contract explicit for attention pipelines.

## Typical Use Cases

- Coordinating Q, K, and V projection passes in transformer inference.
- Packing projected tensors into head-major or sequence-major layouts expected by downstream attention hardware.
- Reusing input activations efficiently across three related projection matrices.
- Supporting fused or partially fused projection flows in accelerator compilers.

## Interfaces and Signal-Level Behavior

- Inputs are hidden-state tensor tiles, projection weights or weight handles, bias if supported, and model-shape metadata such as head count and head dimension.
- Outputs provide Q, K, and V tensor tiles with valid signaling and layout metadata for downstream attention stages.
- Control interfaces configure whether projections are run sequentially, fused, or shared across a scheduling window, along with output layout mode.
- Status signals may expose projection_done, layout_invalid, and accumulator_overflow or tail conditions.

## Parameters and Configuration Knobs

- Hidden width, head count, and head dimension support.
- Operand and accumulator precision.
- Output layout mode such as fused QKV block, separate tensors, head-major, or token-major arrangement.
- Optional fused bias and requantization behavior.

## Internal Architecture and Dataflow

The helper generally wraps one or more GEMM-like compute engines with input reuse, weight-bank selection, and output rearrangement tuned for transformer projections. The crucial contract is how projected outputs are partitioned and ordered across heads and tokens, because downstream attention-score and value-mixing stages depend on that ordering exactly.

## Clocking, Reset, and Timing Assumptions

The block assumes projection weights and hidden-state layouts match the compiler-exported model format. Reset clears in-flight projection context. If Q, K, and V are produced in several passes, the validity and completion semantics for partially available outputs must be explicit so later stages do not consume a mixed batch.

## Latency, Throughput, and Resource Considerations

The cost is dominated by the underlying GEMM work and by output packing bandwidth. Throughput gains come mainly from input reuse and reduced memory traffic relative to launching three unrelated projections. The main tradeoff is between a specialized transformer-friendly interface and generic matrix-multiply flexibility.

## Verification Strategy

- Compare Q, K, and V outputs against a software transformer reference across several tensor shapes and head counts.
- Verify output layout and head partitioning explicitly rather than only comparing flattened buffers.
- Stress tail handling when hidden width or sequence length is not an exact tile multiple.
- Check fused bias and quantization behavior against model-export assumptions.

## Integration Notes and Dependencies

QKV Projection Helper sits between Embedding or prior GEMM layers and Attention Score Unit or later value-aggregation stages. It should align closely with GEMM Engine, Tensor DMA, and the model compiler on tensor layout and weight packing conventions.

## Edge Cases, Failure Modes, and Design Risks

- A head-order or layout mismatch here corrupts the whole attention path while leaving local arithmetic apparently correct.
- Treating QKV projection as three independent GEMMs can waste memory bandwidth and complicate synchronization.
- If partial output readiness is underspecified, downstream attention stages may consume mismatched Q, K, and V tensors.

## Related Modules In This Domain

- gemm_engine
- attention_score_unit
- embedding_lookup
- tensor_dma

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the QKV Projection Helper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
