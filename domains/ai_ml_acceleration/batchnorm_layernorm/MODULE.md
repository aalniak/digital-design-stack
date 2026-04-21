# BatchNorm/LayerNorm

## Overview

BatchNorm/LayerNorm computes normalization statistics and applies affine scaling and bias according to the configured normalization mode. It provides a reusable normalization stage for inference accelerators across convolutional and sequence models.

## Domain Context

Normalization layers stabilize neural network activations and are common in CNNs, MLPs, and transformers, though the exact statistics and semantics differ between batch normalization and layer normalization. In accelerators they are often fused with neighboring linear layers or implemented as a dedicated reduction-plus-affine stage.

## Problem Solved

Normalization mixes reduction operations, elementwise arithmetic, and stored parameters in ways that generic MAC units do not capture cleanly. A dedicated block makes reduction domain, epsilon handling, and affine application explicit so model conversion and fusion remain predictable.

## Typical Use Cases

- Applying frozen batch normalization in CNN inference.
- Executing layer normalization across token or channel dimensions in transformer models.
- Fusing affine scale and bias with normalization in post-convolution or post-GEMM paths.
- Evaluating precision requirements of normalization on quantized or mixed-precision models.

## Interfaces and Signal-Level Behavior

- Inputs are tensor elements plus shape metadata, normalization-axis selection, and stored affine parameters where needed.
- Outputs provide normalized tensor elements with valid signaling and optional statistics status.
- Control interfaces configure batchnorm versus layernorm mode, epsilon, affine enable, and reduction dimensions.
- Status signals may expose slice_done, divide_or_reciprocal_overflow, and parameter-invalid conditions.

## Parameters and Configuration Knobs

- Supported normalization modes and reduction axes.
- Input, accumulator, and output precision.
- Affine parameter width and storage interface.
- Streaming tile size and whether statistics are computed on the fly or provided externally.

## Internal Architecture and Dataflow

The block generally contains reduction logic for mean and variance or equivalent statistics, reciprocal square-root support, and affine transform application. The key contract is the exact reduction domain for each mode, because batch normalization and layer normalization are not interchangeable even if the downstream arithmetic looks similar.

## Clocking, Reset, and Timing Assumptions

The unit assumes tensor shapes and normalization axes are supplied correctly by the scheduler and that frozen parameters, when used, are already prepared for inference. Reset clears reduction state. If quantized operation is supported, the numeric domain in which normalization is performed should be explicit so adjacent layers know whether they must dequantize first.

## Latency, Throughput, and Resource Considerations

Normalization is often reduction-limited and can be more control-heavy than pure elementwise activations. Latency depends on whether statistics require a full pass before output can stream or whether partial buffering is used. The main tradeoff is between fusion convenience and the buffering needed to compute accurate normalization statistics.

## Verification Strategy

- Compare outputs against a software reference for batchnorm and layernorm across several tensor shapes.
- Stress epsilon extremes, nearly constant inputs, and large dynamic-range tensors.
- Verify affine parameter application and mode switching boundaries.
- Check quantized or mixed-precision paths for scale and rounding correctness.

## Integration Notes and Dependencies

BatchNorm/LayerNorm commonly follows Conv2D or GEMM and may be fused with Activation Unit or Quantize/Dequantize stages. It should align with compiler or scheduler assumptions about whether normalization is folded into weights upstream or executed explicitly in hardware.

## Edge Cases, Failure Modes, and Design Risks

- Confusing the reduction axis or normalization mode can corrupt a model while leaving individual arithmetic blocks apparently correct.
- Variance and reciprocal precision issues often appear only on corner-case inputs or larger models.
- Partial fusion assumptions can make software and hardware disagree about whether affine parameters are already folded.

## Related Modules In This Domain

- activation_unit
- conv2d_engine
- gemm_engine
- quantize_dequantize

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the BatchNorm/LayerNorm module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
