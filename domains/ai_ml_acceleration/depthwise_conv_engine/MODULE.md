# Depthwise Conv Engine

## Overview

Depthwise Conv Engine applies one spatial kernel per input channel, optionally with channel multipliers, to produce output feature maps with limited cross-channel accumulation. It provides the specialized convolution path used in depthwise-separable networks.

## Domain Context

Depthwise convolution is the per-channel spatial operator used heavily in mobile and efficient CNN architectures. In accelerator stacks it is distinct enough from regular convolution to justify dedicated hardware or at least dedicated control semantics because compute reuse and memory behavior change substantially.

## Problem Solved

Depthwise layers have very different reuse and accumulation structure from standard convolutions, so forcing them through a general Conv2D engine may waste compute or complicate scheduling. A dedicated block makes that special structure explicit and efficient.

## Typical Use Cases

- Running MobileNet-style depthwise layers efficiently.
- Accelerating separable-convolution backbones in low-power vision models.
- Serving as the spatial stage before a pointwise channel-mixing convolution.
- Exploring memory-traffic reductions for sparse per-channel spatial operators.

## Interfaces and Signal-Level Behavior

- Inputs are feature-map tiles, per-channel kernel weights, bias if supported, and shape metadata including channel multiplier and padding.
- Outputs provide depthwise-processed output tiles with valid signaling and optional post-op status.
- Control interfaces configure kernel size, stride, dilation, padding, and quantization behavior.
- Status signals may expose tile_done, channel_tail, and saturation or parameter-invalid conditions.

## Parameters and Configuration Knobs

- Supported kernel dimensions and channel multiplier.
- Input, weight, accumulator, and output precision.
- Tile buffer sizes and line-buffer strategy.
- Optional fused bias, activation, and requantization support.

## Internal Architecture and Dataflow

The engine generally contains per-channel MAC pipelines, window-generation logic, and limited accumulation compared with full channel-mixing convolution. The key contract is whether channels are processed strictly independently or whether grouped or multiplier modes reuse a broader scheduling model, because compiler mapping depends on that distinction.

## Clocking, Reset, and Timing Assumptions

The module assumes feature-map layout and channel ordering match the selected kernel stream. Reset clears partial channel context. If the design supports channel multipliers greater than one, output-channel indexing and writeback order should be documented carefully.

## Latency, Throughput, and Resource Considerations

Depthwise layers are often bandwidth-bound rather than compute-bound because channel reuse is lower than in dense convolution. Throughput depends heavily on feature-map buffering and on avoiding idle cycles during channel tails. A specialized engine can save power and simplify scheduling even if peak MAC utilization is lower than in dense Conv2D.

## Verification Strategy

- Compare output against a software depthwise-convolution reference across several kernel sizes and multipliers.
- Stress padding edges, channel tails, and narrow feature maps.
- Verify output-channel ordering for multiplier modes.
- Check quantized scaling and any fused post-ops against deployment reference layers.

## Integration Notes and Dependencies

Depthwise Conv Engine usually feeds Pointwise Conv Engine or activation stages in separable-convolution stacks. It should align with Tensor DMA and model compiler scheduling so data layouts stay consistent between depthwise and pointwise phases.

## Edge Cases, Failure Modes, and Design Risks

- Treating depthwise like ordinary convolution can hide channel-order bugs until a separable model is deployed.
- Bandwidth assumptions are easy to get wrong, causing the unit to underperform despite enough MAC capacity.
- Multiplier modes can create subtle output-indexing mistakes that are not obvious in single-channel tests.

## Related Modules In This Domain

- conv2d_engine
- pointwise_conv_engine
- tensor_dma
- activation_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Depthwise Conv Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
