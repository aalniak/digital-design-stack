# Complex Multiplier

## Overview

complex_multiplier computes the product of two complex numbers and is a core primitive in DSP, communications, and vector-control datapaths.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Complex arithmetic is easy to specify mathematically but easy to misalign numerically in hardware. Sign handling, scaling, and pipeline alignment between real and imaginary paths must be explicit.

## Typical Use Cases

- Rotate or mix I and Q samples.
- Build FFT, beamforming, and matched-filter datapaths.
- Support control or estimation logic in complex coordinates.

## Interfaces and Signal-Level Behavior

- Inputs are real and imaginary parts of both operands.
- Outputs are real and imaginary parts of the product, optionally widened or rounded.
- Some variants add conjugate mode or valid-latency control.

## Parameters and Configuration Knobs

- DATA_WIDTH sets component width.
- SIGNED_MODE defines numeric interpretation.
- OUTPUT_WIDTH or GROWTH_POLICY defines product growth.
- ROUND_MODE controls narrowing if outputs are reduced.
- PIPELINE_STAGES sets latency.

## Internal Architecture and Dataflow

The straightforward implementation uses four real multipliers plus add or subtract stages, though optimized forms may reduce multiplier count. The chosen form affects area, latency, and rounding behavior and should be documented.

## Numeric Format, Clocking, and Timing Assumptions

All components share one numeric format and scaling convention. If outputs are narrowed, the rounding and saturation rules must be explicit. Real and imaginary paths must remain cycle aligned.

## Latency, Throughput, and Resource Considerations

Complex multiply is multiplier-heavy, so DSP mapping and pipeline staging dominate timing. Output growth widens adders and can raise cost quickly.

## Verification Strategy

- Compare against a software complex model.
- Exercise sign and quadrant combinations carefully.
- Verify scaling and rounding on narrowed outputs.
- Check latency alignment between real and imaginary results.

## Integration Notes and Dependencies

complex_multiplier usually feeds FFTs, mixers, and beamformers. It should share scaling conventions with the library's real multiply and MAC primitives.

## Edge Cases, Failure Modes, and Design Risks

- Cross-term sign errors can look numerically plausible but be wrong.
- Optimized reduced-multiplier forms complicate verification.
- Pipeline mismatch between real and imaginary paths silently corrupts downstream math.

## Related Modules In This Domain

- multiplier
- mac_unit
- cordic_engine
- adder_subtractor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Complex Multiplier module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
