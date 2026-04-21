# Systolic Array

## Overview

Systolic Array is a regular grid of multiply-accumulate processing elements that streams operands through the fabric to compute matrix products or related tensor operations. It provides a high-throughput structured compute core for dense linear algebra.

## Domain Context

The systolic array is the iconic dense compute fabric of many modern accelerators, especially for matrix multiplication and convolution lowering. In an accelerator stack it is not just a MAC grid, but a dataflow commitment about operand movement, partial-sum residency, and how compilers schedule work.

## Problem Solved

Large neural workloads demand far more multiply-accumulate throughput than scalar or loosely arranged compute can deliver efficiently. A dedicated systolic fabric makes operand reuse and communication structure explicit, enabling high utilization when the scheduler and memory system cooperate.

## Typical Use Cases

- Accelerating matrix multiplication for transformers and MLP layers.
- Serving as the compute core for lowered convolution workloads.
- Exploring dataflow mappings such as weight-stationary or output-stationary execution.
- Providing the dense compute heart of a compiler-targeted ML accelerator.

## Interfaces and Signal-Level Behavior

- Inputs are operand tiles, preload or partial-sum context, and array-scheduling metadata for the current compute wave.
- Outputs provide accumulated tile results and completion or drain status for the active wavefront.
- Control interfaces configure tile dimensions, preload mode, operand skewing policy, and precision.
- Status signals may expose array_busy, drain_complete, and overflow or shape-tail conditions.

## Parameters and Configuration Knobs

- Array dimensions and processing-element precision.
- Supported accumulation width and saturation policy.
- Preload or partial-sum injection support.
- Dataflow configuration if the array supports more than one scheduling mode.

## Internal Architecture and Dataflow

A systolic array consists of multiply-accumulate elements connected in a regular data-moving fabric with edge injection and result drain paths. The architectural contract should define how operands enter, how many cycles are required to fill and drain the array, and whether outputs are final or partial, because scheduler correctness depends on those timing facts.

## Clocking, Reset, and Timing Assumptions

The array assumes Tensor DMA or a scheduler will supply correctly skewed or sequenced tiles according to the supported dataflow. Reset clears in-flight partial sums and wavefront state. If the array supports several operand precisions or mixed-precision modes, the active mode boundary should be explicit so wavefronts do not mix incompatible arithmetic.

## Latency, Throughput, and Resource Considerations

The array often defines peak TOPS, but real performance depends on keeping it fed and on matching model tiles to array shape. Fill and drain overhead, not just steady-state MAC rate, matters for small or irregular layers. The major tradeoff is between a rigid efficient fabric and the flexibility needed for diverse layer shapes.

## Verification Strategy

- Compare tile outputs against a software matmul reference across many shapes, including fill and drain edges.
- Stress partial-sum preload and multi-wave accumulation cases.
- Verify array timing model and latency for scheduler-visible operations.
- Check precision, overflow, and mixed-mode behavior against the intended arithmetic contract.

## Integration Notes and Dependencies

Systolic Array usually works under GEMM-oriented control and depends heavily on Tensor DMA and compiler tiling. It should align with Quantize/Dequantize, Activation, and post-op fusion logic so results leave the fabric in the numeric domain expected by later stages.

## Edge Cases, Failure Modes, and Design Risks

- A correct array datapath can still underperform badly if its scheduling assumptions are not exposed clearly to software.
- Small shape mismatches and fill-drain overheads are easy to ignore in synthetic benchmarks.
- If partial-sum semantics are vague, larger layers may fail only when split across several waves.

## Related Modules In This Domain

- gemm_engine
- tensor_dma
- sparse_decode_unit
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Systolic Array module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
