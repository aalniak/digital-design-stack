# Quantize/Dequantize

## Overview

Quantize/Dequantize converts tensor values between integer and higher-precision numeric domains using scale, zero-point, and rounding policy appropriate to the deployment scheme. It provides the explicit numeric transition stage for quantized inference pipelines.

## Domain Context

Quantization and dequantization are the numeric-boundary blocks that let an accelerator move between integer-efficient compute and higher-precision reference domains. In AI/ML acceleration they define how real-valued model semantics are approximated by scaled integers at layer boundaries and fused post-op points.

## Problem Solved

Quantized models only behave correctly if numeric-domain transitions are applied exactly where and how the exported model expects. A dedicated conversion block makes scale, zero point, saturation, and rounding semantics explicit so layers do not silently disagree about value meaning.

## Typical Use Cases

- Requantizing accumulator outputs down to int8 or similar activation precision.
- Dequantizing integer tensors for normalization or activation operations that need wider precision.
- Bridging mixed-precision layers in hybrid accelerator pipelines.
- Supporting calibration and validation of quantized model deployment in hardware.

## Interfaces and Signal-Level Behavior

- Inputs are tensor elements plus scale, zero-point, and mode metadata indicating the source and destination domain.
- Outputs provide converted tensor elements with valid signaling and optional saturation or clipping status.
- Control interfaces configure per-tensor versus per-channel scaling, rounding mode, and saturation behavior.
- Status signals may expose scale_invalid, overflow, and conversion_done or slice_done conditions.

## Parameters and Configuration Knobs

- Supported source and destination precisions.
- Per-tensor or per-channel scale support.
- Rounding mode, saturation policy, and zero-point range.
- Vector-lane parallelism and coefficient storage or fetch interface.

## Internal Architecture and Dataflow

The block usually contains multiply and shift or reciprocal logic, zero-point adjustment, rounding, clipping, and output packing. The key contract is where this conversion lives relative to bias, activation, and normalization, because quantized inference accuracy depends heavily on that exact ordering.

## Clocking, Reset, and Timing Assumptions

The module assumes scale and zero-point values come from a calibration or compiler flow consistent with the deployed model. Reset clears coefficient and pipeline state. If per-channel scaling is supported, the mapping between channels and scale coefficients must stay aligned through any layout transformation.

## Latency, Throughput, and Resource Considerations

Conversion arithmetic is modest compared with GEMM or convolution, but the unit is touched at many layer boundaries and so can become a throughput bottleneck if underprovisioned. The main tradeoff is conversion flexibility versus lane width and coefficient bandwidth.

## Verification Strategy

- Compare conversion results against a software quantization reference across many scales, zero points, and rounding modes.
- Stress saturation limits, negative ranges, and per-channel scale indexing.
- Verify ordering when fused with bias, activation, or normalization stages.
- Run end-to-end quantized model fragments to ensure small local conversion errors do not compound unexpectedly.

## Integration Notes and Dependencies

Quantize/Dequantize sits between almost every major compute stage in a quantized accelerator, including Conv2D, GEMM, Activation, and Detector Postprocessor paths. It should align tightly with compiler-generated calibration metadata and with on-chip tensor layout so per-channel coefficients attach to the intended dimension.

## Edge Cases, Failure Modes, and Design Risks

- A tiny mismatch in rounding or zero-point semantics can materially change deployed model accuracy.
- Per-channel scale indexing is a frequent source of silent layer corruption after layout transforms.
- If the block?s placement relative to fused post-ops is vague, software and hardware may implement different graphs while using the same names.

## Related Modules In This Domain

- conv2d_engine
- gemm_engine
- activation_unit
- batchnorm_layernorm

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Quantize/Dequantize module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
