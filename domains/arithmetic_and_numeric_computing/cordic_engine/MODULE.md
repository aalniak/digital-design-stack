# CORDIC Engine

## Overview

cordic_engine computes rotations, vectoring operations, and related transcendental functions using iterative shift-add steps instead of large multiplier arrays. It is a classic reusable block for trigonometry and coordinate conversion.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Functions such as sine, cosine, magnitude, and angle are expensive if every block invents its own approach. cordic_engine provides a shared approximation structure with documented precision and scaling behavior.

## Typical Use Cases

- Compute sine and cosine for NCO or rotation logic.
- Convert between Cartesian and polar forms.
- Estimate vector magnitude or angle in fixed-point pipelines.

## Interfaces and Signal-Level Behavior

- Inputs depend on mode and may include x, y, angle, start, or valid.
- Outputs may include rotated coordinates, magnitude, angle, or trig values.
- Iterative versions may expose busy and done signals; pipelined versions use fixed latency.

## Parameters and Configuration Knobs

- DATA_WIDTH sets internal precision.
- ITERATIONS defines accuracy.
- MODE_SET selects supported operations.
- SCALE_COMP_EN enables gain compensation.
- PIPELINED_EN chooses iterative or fully pipelined form.

## Internal Architecture and Dataflow

CORDIC performs a sequence of micro-rotations implemented with shifts and adds. The crucial contract points are scaling convention, supported angle range, and whether gain compensation is built in or expected externally.

## Numeric Format, Clocking, and Timing Assumptions

Fixed-point scaling and angle encoding must be explicit. Iterative variants require a clear handshake or busy contract. Quantization error is part of the design and should be acknowledged, not hidden.

## Latency, Throughput, and Resource Considerations

CORDIC trades multiplier cost for iterations. Fully pipelined forms can be high-throughput but expensive, while iterative forms are smaller but slower.

## Verification Strategy

- Compare results against a high-precision model.
- Exercise quadrant and sign boundaries carefully.
- Verify gain compensation policy.
- Check iterative handshake or pipelined latency exactly.

## Integration Notes and Dependencies

cordic_engine is common under phase rotation, magnitude estimation, and trig support logic. Standard angle encoding across the library makes it much easier to reuse.

## Edge Cases, Failure Modes, and Design Risks

- Angle-format mismatches are the main integration hazard.
- Forgetting or double-applying CORDIC gain compensation creates amplitude errors.
- Iteration count may meet average error goals while still failing worst-case inputs.

## Related Modules In This Domain

- complex_multiplier
- divider
- square_root
- barrel_shifter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CORDIC Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
