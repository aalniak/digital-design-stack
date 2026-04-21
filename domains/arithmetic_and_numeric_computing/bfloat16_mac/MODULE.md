# Bfloat16 MAC

## Overview

bfloat16_mac performs multiply-accumulate on bfloat16 operands with a documented accumulator format and rounding policy. It is a reduced-precision floating-point primitive aimed at ML-style workloads.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

bfloat16 is useful only when every block agrees on special-value handling, accumulator precision, and fused-versus-non-fused behavior. bfloat16_mac makes those assumptions explicit.

## Typical Use Cases

- Build neural-network accumulation lanes.
- Provide lower-area floating-point MAC chains with wide exponent range.
- Accelerate approximate numeric kernels that do not need full fp32 precision.

## Interfaces and Signal-Level Behavior

- Inputs usually include two bfloat16 operands and accumulator or clear control.
- Outputs include result and optional special-case or exception flags.
- Vector or stream wrappers may add valid-ready around the core.

## Parameters and Configuration Knobs

- ACC_WIDTH or ACC_FORMAT defines accumulation precision.
- ROUND_MODE selects rounding behavior.
- SPECIAL_CASE_EN controls NaN, infinity, and denormal support.
- FUSED_MODE selects single-round versus staged behavior.
- PIPELINE_STAGES sets latency.

## Internal Architecture and Dataflow

The operator unpacks sign, exponent, and mantissa, forms a product, aligns it to the accumulator, then normalizes and rounds. Accumulator precision and fused behavior dominate numerical quality.

## Numeric Format, Clocking, and Timing Assumptions

The module must state exactly which subset of IEEE-like behavior it implements. Denormal policy and NaN propagation must be explicit rather than implied.

## Latency, Throughput, and Resource Considerations

This operator is cheaper than wide floating-point MACs but still dominated by alignment, normalization, and rounding logic. Accumulator width strongly affects both timing and area.

## Verification Strategy

- Compare against a golden numerical model.
- Exercise NaN, infinity, zero, and denormal policy.
- Check rounding boundaries and long accumulation behavior.
- Verify fixed latency and flag timing.

## Integration Notes and Dependencies

bfloat16_mac usually lives inside systolic arrays or vector lanes. It should pair with explicit format-conversion blocks rather than ad hoc reinterpretation from other float formats.

## Edge Cases, Failure Modes, and Design Risks

- Accumulator precision mismatch is a major integration risk.
- Fused and non-fused behavior can change model quality materially.
- Special-case simplifications are acceptable only if every consumer knows them.

## Related Modules In This Domain

- fp16_mac
- mac_unit
- multiplier
- fixed_to_float_converter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bfloat16 MAC module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
