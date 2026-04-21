# Conv2D Engine

## Overview

Conv2D Engine computes two-dimensional convolution over input feature maps using programmable kernels, stride, padding, and channel accumulation behavior. It provides the primary dense spatial compute primitive for CNN inference.

## Domain Context

Conv2D is the core spatial operator behind many CNNs and some hybrid vision networks. In an accelerator stack it is often the largest compute consumer, tightly coupled to weight tiling, feature-map buffering, and quantization policy.

## Problem Solved

Convolution layers combine heavy MAC demand with nontrivial data movement and layout rules. A dedicated engine keeps kernel geometry, tiling, padding, and accumulation semantics explicit rather than forcing everything through an opaque generic matrix wrapper.

## Typical Use Cases

- Running feature-extraction layers in image classification, detection, and segmentation models.
- Accelerating CNN backbones where convolution dominates compute cost.
- Serving as a fused op target with bias, activation, or normalization post-ops.
- Exploring weight-stationary versus output-stationary dataflow tradeoffs in hardware research.

## Interfaces and Signal-Level Behavior

- Inputs are feature-map tiles, weight tiles, bias terms if supported, and layer-shape metadata such as stride, padding, and channel counts.
- Outputs provide output-feature-map tiles with valid signaling and optional post-op status.
- Control interfaces configure kernel size, dilation, padding mode, quantization parameters, and tiling schedule.
- Status signals may expose tile_done, shape_invalid, and accumulator_saturation or underflow conditions.

## Parameters and Configuration Knobs

- Supported kernel sizes, stride, dilation, and channel parallelism.
- Input, weight, accumulator, and output precision.
- On-chip tile buffer sizes and dataflow mode.
- Optional fused bias, activation, or requantization support.

## Internal Architecture and Dataflow

A Conv2D engine typically contains MAC arrays, line or tile buffers, sliding-window generation, partial-sum accumulation, and post-op hooks. The contract should say clearly which tensor layout is native and whether padding is synthesized internally or pre-applied upstream, because many deployment bugs come from layout and boundary assumptions rather than from convolution math itself.

## Clocking, Reset, and Timing Assumptions

The engine assumes the scheduler delivers tiles in the expected order and provides consistent quantization scales for inputs and weights. Reset clears partial sums and tile context. If layers are split across several tiles or channel groups, accumulation ownership and writeback timing should be explicit so the final output is deterministic.

## Latency, Throughput, and Resource Considerations

This block usually dominates area, power, and throughput budgets. Performance depends as much on SRAM reuse and DMA scheduling as on MAC count. The practical tradeoff is between keeping arrays busy and avoiding precision loss or output-stationary spills under large channels or awkward feature-map shapes.

## Verification Strategy

- Compare output tiles against a software convolution reference across varied kernel shapes, padding, and stride.
- Stress boundary conditions, channel tails, and partial-tile accumulation.
- Verify fused post-op ordering such as bias before activation or requantization.
- Check layout interpretation and quantized scaling using representative deployment models.

## Integration Notes and Dependencies

Conv2D Engine works closely with Tensor DMA, Activation Unit, BatchNorm/LayerNorm, and Quantize/Dequantize logic. It should align with model compiler assumptions about tensor layout and whether weight transforms or folding have already been performed offline.

## Edge Cases, Failure Modes, and Design Risks

- A tensor-layout mismatch can make output maps look numerically reasonable while still being wrong everywhere.
- Padding and stride corner cases are easy to under-test but critical for model correctness.
- If tiling accumulation semantics are vague, large-channel layers may fail only in deployment-sized models.

## Related Modules In This Domain

- depthwise_conv_engine
- pointwise_conv_engine
- tensor_dma
- activation_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Conv2D Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
