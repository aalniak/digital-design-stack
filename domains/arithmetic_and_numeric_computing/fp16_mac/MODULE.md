# Fp16 MAC

## Overview

fp16_mac performs multiply-accumulate on fp16 operands with a documented accumulator format and rounding policy. It is a reduced-precision floating-point compute primitive for inference and signal-processing workloads.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Half-precision floating-point is useful only when accumulator precision, special-value handling, and fused behavior are clear. fp16_mac provides one reusable contract for those choices.

## Typical Use Cases

- Implement fp16 inference or matrix-compute lanes.
- Build reduced-precision signal-processing kernels.
- Provide a lower-area floating-point MAC than full fp32.

## Interfaces and Signal-Level Behavior

- Inputs include two fp16 operands and accumulation control or accumulator input.
- Outputs include result and optional status or special-case flags.
- Lane or stream wrappers may add valid-ready control.

## Parameters and Configuration Knobs

- ACC_FORMAT defines accumulator precision.
- ROUND_MODE sets rounding behavior.
- FUSED_MODE selects single-round versus staged behavior.
- SPECIAL_CASE_EN controls NaN, infinity, and denormal support.
- PIPELINE_STAGES sets latency.

## Internal Architecture and Dataflow

The operator unpacks sign, exponent, and mantissa, forms a product, aligns it to the accumulator, then normalizes and rounds. Accumulator precision and fused behavior dominate both cost and numeric quality.

## Numeric Format, Clocking, and Timing Assumptions

The module must document which floating-point corner cases are fully supported and which are simplified. Denormal handling and NaN propagation are especially important.

## Latency, Throughput, and Resource Considerations

Normalization and alignment dominate timing more than the multiply itself. Pipelining is common. Resource use depends strongly on accumulator width and flag logic.

## Verification Strategy

- Compare against a high-level numerical model.
- Exercise zero, sign, NaN, infinity, and denormal behavior.
- Check fused versus non-fused rounding if configurable.
- Verify fixed latency and flag timing.

## Integration Notes and Dependencies

fp16_mac belongs in vector lanes, systolic arrays, and reduced-precision compute blocks. It should not be treated as interchangeable with bfloat16 MAC without an explicit conversion boundary.

## Edge Cases, Failure Modes, and Design Risks

- Assuming fp16 and bfloat16 behave the same is a common error.
- Accumulator precision can dominate model quality and must be surfaced clearly.
- Special-case simplifications require cross-team agreement.

## Related Modules In This Domain

- bfloat16_mac
- mac_unit
- fixed_to_float_converter
- float_to_fixed_converter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Fp16 MAC module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
