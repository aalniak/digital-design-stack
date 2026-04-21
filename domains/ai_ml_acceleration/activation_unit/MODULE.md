# Activation Unit

## Overview

Activation Unit applies elementwise nonlinear functions such as ReLU, GELU, sigmoid, tanh, or related approximations to tensor data streams. It provides the post-arithmetic nonlinearity stage used throughout inference accelerators.

## Domain Context

Activation functions are the nonlinear stage that gives neural networks representational power beyond pure matrix algebra. In an accelerator stack this unit is usually a small but frequently used stage placed after MAC-heavy layers, where precision, clipping, and fusion semantics matter a great deal.

## Problem Solved

Compute arrays are optimized for linear algebra, but neural workloads also need fast, well-defined nonlinear transforms. A dedicated activation block makes approximation mode, fixed-point scaling, and tensor element cadence explicit so layers can be fused and verified consistently.

## Typical Use Cases

- Applying ReLU-like activations after convolution or GEMM outputs.
- Approximating GELU or sigmoid in transformer or MLP inference pipelines.
- Serving as a reusable fused post-op stage behind MAC arrays.
- Supporting comparative evaluation of activation precision versus hardware cost.

## Interfaces and Signal-Level Behavior

- Inputs are tensor elements or vector lanes plus valid markers and often scale or mode context from the layer scheduler.
- Outputs provide activated tensor elements with aligned valid signaling and optional saturation flags.
- Control interfaces configure activation type, approximation profile, clipping behavior, and quantization domain.
- Status signals may expose mode_invalid, overflow, and pipeline_busy conditions.

## Parameters and Configuration Knobs

- Supported activation families and approximation method.
- Input and output precision, including integer or mixed-precision operation.
- Vector-lane parallelism and pipelining depth.
- Optional fused bias or clamp support if the unit is used as a post-op stage.

## Internal Architecture and Dataflow

The unit typically contains comparison and clamp logic for piecewise-linear modes or lookup and polynomial-approximation machinery for smoother activations. The important contract is that the numeric interpretation of the input tensor, including scale and zero point when quantized, must be clear because an otherwise correct activation can still be functionally wrong if applied in the wrong numeric domain.

## Clocking, Reset, and Timing Assumptions

The module assumes tensor elements arrive already aligned to the intended scale and ordering for the chosen layer. Reset clears pipeline state. If approximation mode depends on external coefficients or LUTs, the configuration boundary and activation timing should be explicit to avoid mixing precision modes within one tensor.

## Latency, Throughput, and Resource Considerations

Activation logic is usually cheaper than convolutions or GEMM but still sits on critical throughput paths because it touches every element. Latency should be bounded and preferably pipeline-friendly. The meaningful tradeoff is approximation fidelity versus area and timing closure, not just raw element rate.

## Verification Strategy

- Compare outputs against a floating-point or quantized software reference over representative ranges.
- Stress saturation, denormalized quantized inputs, and exact boundary points such as zero crossings.
- Check mode-switch timing so no tensor mixes two activation behaviors inadvertently.
- Measure approximation error for non-piecewise functions under target model distributions.

## Integration Notes and Dependencies

Activation Unit commonly follows Conv2D, GEMM, Pointwise Convolution, or BatchNorm/LayerNorm stages and may be fused with them by a scheduler. It should align with Quantize/Dequantize policy so the system knows whether activation happens in integer, mixed, or floating-point space.

## Edge Cases, Failure Modes, and Design Risks

- A small scale or zero-point mismatch can distort a whole model even if the activation formula is implemented correctly.
- Approximation choices that look harmless in isolation can materially hurt certain models or layers.
- Fused post-op usage can hide ordering assumptions, such as whether activation happens before or after requantization.

## Related Modules In This Domain

- conv2d_engine
- gemm_engine
- batchnorm_layernorm
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Activation Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
