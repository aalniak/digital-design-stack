# Sparse Decode Unit

## Overview

Sparse Decode Unit interprets sparse tensor or weight encodings and expands them into value-index streams or dense tiles suitable for downstream compute. It provides the structural bridge between compressed sparse data and execution hardware.

## Domain Context

Sparse decode logic exists to turn compressed or structured sparse representations back into dense-enough streams for accelerator consumption or to exploit sparsity-aware execution modes. In AI/ML accelerators it sits at the boundary between compact model representations and regular compute arrays.

## Problem Solved

Sparsity can save memory bandwidth and storage, but only if the hardware can reconstruct the intended nonzero structure efficiently and deterministically. A dedicated sparse decoder keeps encoding format, index semantics, and zero-fill policy explicit rather than burying them in ad hoc scheduler logic.

## Typical Use Cases

- Decoding structured or unstructured sparse weights before GEMM or convolution.
- Expanding sparse activation streams for mixed sparse-dense execution.
- Supporting compressed model storage with hardware-assisted unpacking.
- Evaluating sparsity tradeoffs in accelerator research without rewriting every compute kernel.

## Interfaces and Signal-Level Behavior

- Inputs are compressed sparse payloads such as value streams, index streams, and block or tile boundary metadata.
- Outputs provide decoded nonzero tuples, expanded dense tiles, or hybrid streams with valid signaling.
- Control interfaces configure sparse format, zero-fill policy, and output mode.
- Status signals may expose format_invalid, index_overflow, and decode_done conditions.

## Parameters and Configuration Knobs

- Supported sparse formats, such as coordinate, run-length, block-sparse, or custom compiler-defined patterns.
- Maximum nonzero count per tile or block.
- Index width, value precision, and output packing mode.
- Whether the unit emits dense tensors, value-index pairs, or scheduler-friendly masks.

## Internal Architecture and Dataflow

The unit typically contains compressed-format parsing, index accumulation, optional zero-fill generation, and output packing. The key contract is the exact sparse encoding and output interpretation, because mismatches in index basis or block semantics can silently corrupt the compute result even when values themselves are correct.

## Clocking, Reset, and Timing Assumptions

The module assumes compressed streams are framed in complete sparse blocks or tiles and that index semantics match the targeted compute kernel layout. Reset clears decoder state and partial index accumulators. If several sparse formats are supported, the safe activation boundary between formats should be explicit.

## Latency, Throughput, and Resource Considerations

Sparse decode performance depends heavily on nonzero density and format regularity. Some formats decode into steady streams; others create bursty output and control overhead. The main tradeoff is bandwidth savings versus decode complexity and the degree to which downstream compute can actually exploit the sparsity pattern.

## Verification Strategy

- Compare decoded output against a software sparse-format reference for every supported format.
- Stress empty tiles, dense worst-case tiles, and malformed index streams.
- Verify zero-fill and output ordering explicitly for both dense and tuple-style modes.
- Check interaction with downstream compute kernels using representative sparse model fragments.

## Integration Notes and Dependencies

Sparse Decode Unit often feeds GEMM, Systolic Array, or Conv2D-related wrappers and depends on Tensor DMA or parameter storage delivering compressed blocks in the expected order. It should align closely with compiler-generated sparse formats and pruning policies.

## Edge Cases, Failure Modes, and Design Risks

- A sparse-format mismatch can break accuracy globally while leaving all local arithmetic apparently correct.
- Sparse decoding overhead can erase expected efficiency gains if the output pattern is too bursty for downstream hardware.
- Index-basis confusion, especially around block-sparse layouts, is a common integration failure mode.

## Related Modules In This Domain

- tensor_dma
- gemm_engine
- systolic_array
- conv2d_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Sparse Decode Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
