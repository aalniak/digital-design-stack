# Pointwise Conv Engine

## Overview

Pointwise Conv Engine performs 1x1 convolution across channels, mixing per-pixel channel vectors into new output channels with no spatial kernel extent beyond a single position. It provides the channel-projection counterpart to depthwise spatial filtering.

## Domain Context

Pointwise convolution is the 1x1 channel-mixing stage that commonly follows depthwise convolution in separable networks and also appears as a compact channel projection in many CNN architectures. In accelerator stacks it often maps well to GEMM-like hardware but still carries convolution-specific layout expectations.

## Problem Solved

Although 1x1 convolution resembles matrix multiplication, it is often scheduled and fused as part of a separable-convolution pipeline with its own layout and buffering expectations. A dedicated pointwise block keeps that deployment pattern explicit.

## Typical Use Cases

- Mixing channels after depthwise convolution in mobile CNNs.
- Applying 1x1 projection or expansion layers in bottleneck blocks.
- Serving as a lightweight per-pixel channel transform in vision backbones.
- Supporting separable-convolution pipelines with dedicated channel-mixing hardware.

## Interfaces and Signal-Level Behavior

- Inputs are feature-map tiles or pixel-channel vectors, 1x1 weights, bias if supported, and shape metadata.
- Outputs provide output-feature-map tiles with valid signaling and optional fused post-op status.
- Control interfaces configure channel counts, quantization policy, and fusion options such as activation or requantization.
- Status signals may expose tile_done, channel_tail, and accumulator_saturation conditions.

## Parameters and Configuration Knobs

- Input and output channel parallelism.
- Operand and accumulator precision.
- Tile buffering strategy and layout mode.
- Optional fused bias, activation, and requantization support.

## Internal Architecture and Dataflow

The engine often reuses GEMM-style inner products but with control and buffering specialized for per-spatial-position channel mixing. The contract should say whether it is simply a thin wrapper over GEMM or a dedicated kernel with feature-map-aware addressing, because compiler scheduling and fusion choices depend on that distinction.

## Clocking, Reset, and Timing Assumptions

The module assumes feature-map layout matches the expected channel-vector ordering and that any preceding depthwise stage emits tiles in a compatible order. Reset clears partial accumulation state. If fused after depthwise processing, the boundary between the two stages should define whether intermediate requantization occurs.

## Latency, Throughput, and Resource Considerations

Pointwise layers are dense in MAC count and often dominate separable-network compute after the depthwise stage. Throughput depends on channel reuse and SRAM bandwidth more than on spatial window generation. The main tradeoff is between general GEMM flexibility and a more specialized, lower-overhead per-pixel flow.

## Verification Strategy

- Compare output against a software 1x1 convolution reference over varied channel counts and tile shapes.
- Stress channel tails, fused post-op paths, and quantized scaling.
- Verify layout compatibility with outputs from the paired depthwise stage.
- Check accumulation and writeback across multi-tile channel partitions.

## Integration Notes and Dependencies

Pointwise Conv Engine commonly follows Depthwise Conv Engine and interfaces with Activation Unit and Quantize/Dequantize logic. It should align with compiler fusion passes that treat depthwise plus pointwise as one separable block.

## Edge Cases, Failure Modes, and Design Risks

- A subtle layout mismatch between depthwise output and pointwise input can corrupt separable models badly.
- Treating pointwise as generic GEMM without documenting spatial indexing can confuse scheduler and verification teams.
- Post-op fusion ordering can materially affect quantized accuracy.

## Related Modules In This Domain

- depthwise_conv_engine
- conv2d_engine
- gemm_engine
- activation_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pointwise Conv Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
