# GEMM Engine

## Overview

GEMM Engine performs tiled matrix multiplication with configurable dimensions, precision, and accumulation behavior. It provides the primary dense linear-algebra primitive for neural-network inference and related tensor workloads.

## Domain Context

General matrix multiplication is the universal linear-algebra kernel behind fully connected layers, transformer projections, attention substeps, and many compiler-lowered operators. In an accelerator stack it is the dense compute backbone from which many higher-level kernels are built.

## Problem Solved

Many models can be lowered to matrix multiplications, but performance depends on tiling, accumulation precision, and memory movement rather than multiplication alone. A dedicated GEMM engine makes those scheduling and numeric contracts explicit so compilers and neighboring blocks can target it predictably.

## Typical Use Cases

- Running fully connected and MLP layers.
- Executing transformer projections and attention-related matrix products.
- Serving as the fallback compute primitive for compiler-lowered tensor ops.
- Evaluating systolic versus general tiled matrix-multiply dataflows in hardware prototypes.

## Interfaces and Signal-Level Behavior

- Inputs are matrix tiles for A and B, optional bias or accumulator preload, and dimension metadata for the active problem.
- Outputs provide matrix tile results with valid signaling and optional post-op or accumulation status.
- Control interfaces configure tile shape, transpose mode, accumulation depth, and quantization or scaling behavior.
- Status signals may expose tile_done, shape_invalid, and accumulator_overflow conditions.

## Parameters and Configuration Knobs

- Supported tile sizes and matrix dimension limits.
- Input, weight, accumulator, and output precision.
- Dataflow mode such as output stationary or weight stationary if configurable.
- Optional fused bias, activation, or requantization support.

## Internal Architecture and Dataflow

A GEMM engine usually contains MAC arrays or a systolic fabric, tile buffers, partial-sum accumulation, and writeback control. The architectural contract should define whether it expects pretransposed weights, how accumulation across K tiles is sequenced, and whether outputs are final or partial, because those details dominate compiler integration.

## Clocking, Reset, and Timing Assumptions

The engine assumes Tensor DMA or a scheduler delivers tiles in an order consistent with the chosen dataflow and that quantized operands arrive with known scale policy. Reset clears partial sums and in-flight tile context. If transpose or stride modes exist, their exact memory-layout interpretation should be documented clearly.

## Latency, Throughput, and Resource Considerations

This block typically dominates accelerator throughput metrics and often drives the memory hierarchy design. Achieved performance depends on keeping the array fed and on minimizing spill between tile phases. The key tradeoff is between flexible shapes and peak utilization on a narrower set of favored tile geometries.

## Verification Strategy

- Compare outputs against a software GEMM reference across many M, N, and K shapes including tails.
- Stress accumulation across multiple K tiles and partial-result writeback.
- Verify transpose and layout modes against known matrix examples.
- Check fused post-op ordering and quantized scaling on representative model kernels.

## Integration Notes and Dependencies

GEMM Engine sits at the center of AI/ML acceleration, working with Tensor DMA, Quantize/Dequantize, Activation Unit, and QKV or embedding-related wrappers. It should align tightly with the compiler stack, because tile scheduling assumptions are as important as arithmetic correctness.

## Edge Cases, Failure Modes, and Design Risks

- A tile-accumulation contract that is vague or wrong can break large layers while small tests still pass.
- Data-layout mismatches are a common source of plausible but incorrect output tensors.
- If fused post-op ordering differs from compiler expectation, quantized models may degrade sharply.

## Related Modules In This Domain

- tensor_dma
- qkv_projection_helper
- activation_unit
- batchnorm_layernorm

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the GEMM Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
