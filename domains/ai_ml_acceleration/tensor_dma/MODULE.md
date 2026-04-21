# Tensor DMA

## Overview

Tensor DMA transfers tensor tiles and parameter blocks between memory domains and on-chip accelerator buffers using tensor-aware strides, shapes, and layout metadata. It provides the data logistics layer that keeps compute engines supplied and results drained.

## Domain Context

Tensor DMA is the memory-movement backbone of an AI accelerator. Its job is to move activations, weights, and partial results between external memory and on-chip buffers while preserving tensor layout, stride semantics, and synchronization with compute tiles.

## Problem Solved

Even the best compute array stalls if tensor movement is naive. A generic DMA is often insufficient because tensor workloads rely on multidimensional strides, channel grouping, and tiled reuse patterns. A dedicated tensor-aware mover makes those semantics explicit.

## Typical Use Cases

- Loading activation and weight tiles for GEMM, convolution, and attention workloads.
- Writing back output tiles in the layout expected by later layers or host software.
- Supporting double buffering and overlap of transfer with compute.
- Converting or traversing tensor layouts that differ between memory and compute-native format.

## Interfaces and Signal-Level Behavior

- Inputs are transfer descriptors specifying source, destination, shape, stride, and layout metadata, plus start or queue control.
- Outputs are data streams to local buffers or completion and status events to the scheduler.
- Control interfaces configure burst behavior, tiling mode, transpose or layout-walk options, and queue depth.
- Status signals may expose transfer_done, descriptor_error, underflow, and backpressure conditions.

## Parameters and Configuration Knobs

- Supported tensor rank and stride count.
- Descriptor queue depth and maximum tile size.
- Burst width and memory interface width.
- Optional layout conversion features such as transpose, channel packing, or padding skip.

## Internal Architecture and Dataflow

Tensor DMA generally contains descriptor fetch and arbitration, multidimensional address generation, burst engines, buffering, and completion tracking. The critical contract is how logical tensor coordinates map to physical memory traversal, because every compute engine built above this block assumes that traversal is exact.

## Clocking, Reset, and Timing Assumptions

The DMA assumes descriptors come from a trusted scheduler that understands the active tensor layout and on-chip buffer ownership. Reset should clear outstanding descriptors or mark them invalid in a documented way. If overlapping transfers and compute are supported, fence and completion semantics should be unambiguous.

## Latency, Throughput, and Resource Considerations

Tensor DMA often determines realized accelerator throughput more than arithmetic peak does. Performance depends on burst efficiency, stride handling, and overlap with compute. The central tradeoff is between flexible tensor layout support and the cost of complex address generation and buffering.

## Verification Strategy

- Validate multidimensional address generation against a software tensor-walk reference for varied shapes and strides.
- Stress small tail tiles, noncontiguous channel layouts, and overlapping queued descriptors.
- Verify completion, fence, and error semantics under backpressure and memory stalls.
- Run end-to-end compute pipelines with real tile schedules to ensure DMA timing matches scheduler expectations.

## Integration Notes and Dependencies

Tensor DMA sits between external memory and almost every compute block, including GEMM, Conv2D, Attention Score, Embedding Lookup, and Systolic Array. It must align tightly with compiler-emitted descriptors, buffer managers, and layout transforms or the entire accelerator becomes fragile.

## Edge Cases, Failure Modes, and Design Risks

- A descriptor-layout mismatch can invalidate whole models without any arithmetic bug.
- Stride and tail handling are common sources of subtle data corruption on non-square or noncontiguous tensors.
- If completion semantics are vague, compute may consume partially transferred tiles or stall unnecessarily.

## Related Modules In This Domain

- gemm_engine
- conv2d_engine
- embedding_lookup
- systolic_array

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Tensor DMA module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
