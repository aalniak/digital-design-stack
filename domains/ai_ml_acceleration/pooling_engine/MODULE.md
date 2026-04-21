# Pooling Engine

## Overview

Pooling Engine performs max, average, or related local reduction over sliding windows on feature maps. It provides spatial downsampling and local aggregation for neural-network inference pipelines.

## Domain Context

Pooling is the spatial reduction stage used to shrink feature maps, aggregate local evidence, and reduce downstream compute in many CNN architectures. In accelerator stacks it is a lower-arithmetic but still layout-sensitive operator that often needs to run at full feature-map bandwidth.

## Problem Solved

Pooling seems simple, but window geometry, padding, stride, and quantized averaging semantics must all match the model exactly. A dedicated block keeps those rules explicit rather than embedding them as ad hoc reductions in general compute kernels.

## Typical Use Cases

- Applying max pooling in CNN feature-extraction pipelines.
- Running average pooling before classifier heads or residual blocks.
- Reducing spatial resolution to lower later compute cost.
- Supporting global pooling variants for compact classification models.

## Interfaces and Signal-Level Behavior

- Inputs are feature-map tiles plus window, stride, and padding metadata.
- Outputs provide reduced feature-map tiles with valid signaling and optional saturation or rounding status.
- Control interfaces configure pooling mode, window geometry, global-pooling selection, and numeric behavior.
- Status signals may expose tile_done, shape_invalid, and accumulation_overflow for average modes.

## Parameters and Configuration Knobs

- Supported pooling modes such as max or average.
- Window size, stride, and padding range.
- Input and output precision and average-rounding policy.
- Tile buffer and line-buffer depth.

## Internal Architecture and Dataflow

The engine generally contains window-generation logic, reduction datapaths, optional averaging divide or reciprocal logic, and output scheduling. The contract should define whether padding values participate in the reduction and how average divisors are formed, because those details vary between frameworks and strongly affect correctness.

## Clocking, Reset, and Timing Assumptions

The block assumes feature-map layout and channel ordering are already aligned to the chosen pooling window traversal. Reset clears buffer state. If global pooling is supported, the scheduler should know whether the whole channel map must be seen before any output is emitted.

## Latency, Throughput, and Resource Considerations

Pooling is usually bandwidth-limited rather than compute-limited. Throughput must match the feature-map rate of neighboring conv layers. The practical tradeoff is between buffering enough rows for window reuse and keeping area and latency reasonable.

## Verification Strategy

- Compare outputs against a software pooling reference for several window sizes, strides, and padding combinations.
- Stress max-pool tie cases and average-pool rounding semantics.
- Verify global-pooling behavior on varying feature-map sizes.
- Check output alignment and tile turnover across partial windows at boundaries.

## Integration Notes and Dependencies

Pooling Engine typically sits between convolution or activation stages and later Conv2D or GEMM layers. It should align with Tensor DMA and compiler schedules on whether pooling is fused, explicit, or replaced by stride in the exported model graph.

## Edge Cases, Failure Modes, and Design Risks

- Framework differences in average-pool divisor or padding treatment can cause silent mismatch to reference models.
- Boundary handling errors often show up only on odd-sized feature maps.
- Assuming pooling is trivial can lead to under-testing despite its ubiquity in deployed CNNs.

## Related Modules In This Domain

- conv2d_engine
- activation_unit
- tensor_dma
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pooling Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
