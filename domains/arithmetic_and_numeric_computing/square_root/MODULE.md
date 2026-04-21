# Square Root

## Overview

square_root computes the principal square root of a non-negative operand under a documented numeric format, latency, and rounding policy. It is a higher-cost arithmetic primitive used when magnitude or normalization must be computed directly rather than approximated.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Square root is expensive enough that teams often avoid specifying its behavior precisely until late. That leads to disagreement about fixed-point scaling, rounding, invalid negative inputs, and iterative versus pipelined timing. square_root gives the stack one reusable contract for that operator.

## Typical Use Cases

- Compute vector magnitude or energy-derived metrics.
- Support normalization and control algorithms that require true root behavior.
- Provide geometric or statistical primitives in DSP and perception pipelines.

## Interfaces and Signal-Level Behavior

- Inputs usually include operand and start or valid control.
- Outputs include root result and optional remainder, inexact, or invalid status.
- Iterative implementations may expose busy or done signals, while pipelined versions expose fixed latency.

## Parameters and Configuration Knobs

- DATA_WIDTH sets operand width.
- FORMAT or FRAC_BITS defines fixed-point scaling when applicable.
- ROUND_MODE selects truncation or rounding behavior.
- IMPLEMENTATION_MODE chooses iterative or pipelined structure.
- NEGATIVE_INPUT_POLICY defines behavior if signed inputs are allowed.

## Internal Architecture and Dataflow

Common hardware approaches include digit-by-digit iterative methods, non-restoring square root, lookup-seeded refinement, or vendor IP wrappers. The key contract points are whether the module returns an exact integer root, a rounded fixed-point root, and whether any remainder or error term is exposed to callers.

## Numeric Format, Clocking, and Timing Assumptions

The numeric format must be explicit. If the module accepts signed inputs, negative-value handling must be documented plainly because real square root is undefined there. Iterative variants require a precise launch and completion protocol.

## Latency, Throughput, and Resource Considerations

Square root is typically higher latency than add or multiply. Iterative designs reduce area but increase cycle count, while pipelined designs raise throughput at greater hardware cost. Internal width and rounding policy strongly affect timing.

## Verification Strategy

- Compare against a high-precision reference across random and boundary inputs.
- Exercise zero, one, maximum exact-square, and near-boundary non-square values.
- Check invalid negative-input policy explicitly if signed mode exists.
- Verify done, busy, or fixed-latency timing exactly.

## Integration Notes and Dependencies

square_root often feeds magnitude estimators, normalization stages, and geometric computations. It should be chosen deliberately, because reciprocal or approximate methods may be better where exactness is not required.

## Edge Cases, Failure Modes, and Design Risks

- Fixed-point scaling mistakes can produce numerically plausible but wrong answers.
- Negative-input behavior is a major integration hazard if left implicit.
- High latency makes this block easy to misuse inside tight feedback loops.

## Related Modules In This Domain

- cordic_engine
- divider
- reciprocal_approximation
- complex_multiplier

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Square Root module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
