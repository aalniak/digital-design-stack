# Barrel Shifter

## Overview

barrel_shifter shifts or rotates a word by a variable amount in one cycle or fixed latency. It is a common support primitive for normalization, alignment, and bit-field operations.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Variable shifts are easy to misimplement around sign extension, wide shift amounts, and rotate semantics. barrel_shifter gives those rules one reusable contract.

## Typical Use Cases

- Normalize values before floating or reciprocal support logic.
- Align or repack fields inside protocol and arithmetic pipelines.
- Support variable logical, arithmetic, or rotate operations in processor-adjacent datapaths.

## Interfaces and Signal-Level Behavior

- Inputs include data, shift amount, and mode select.
- Outputs provide shifted or rotated data and optionally sticky or shifted-out information.
- Pipelined versions may expose a valid signal with fixed latency.

## Parameters and Configuration Knobs

- DATA_WIDTH sets word width.
- SHIFT_MODE enables left, right, arithmetic, or rotate variants.
- AMOUNT_WIDTH sizes the supported shift range.
- STICKY_BIT_EN adds shifted-out indication.
- PIPELINE_STAGES allows retiming.

## Internal Architecture and Dataflow

A barrel shifter is usually a staged mux tree, each stage shifting by a power of two. Arithmetic and rotate modes add sign-fill or wrap logic on top of that base structure.

## Numeric Format, Clocking, and Timing Assumptions

The module should document what happens for shift amounts at or beyond the data width and how signedness affects arithmetic right shift. Registered versions must keep latency fixed.

## Latency, Throughput, and Resource Considerations

Wide mux trees can become timing-heavy. Pipelining is common at large widths or high clocks. Resource cost grows with width and the number of supported modes.

## Verification Strategy

- Check every shift mode and boundary amount.
- Verify sign extension for arithmetic right shift.
- Exercise rotate semantics carefully.
- Confirm sticky or shifted-out bits match a software model.

## Integration Notes and Dependencies

barrel_shifter commonly sits under conversion, normalization, and processor-adjacent arithmetic. Mode encoding and boundary semantics should be consistent across the stack.

## Edge Cases, Failure Modes, and Design Risks

- Arithmetic versus logical right shift confusion is common.
- Large widths can create an unexpected mux-tree critical path.
- Oversized shift counts need explicit semantics or bugs cluster there.

## Related Modules In This Domain

- leading_zero_counter
- fixed_to_float_converter
- float_to_fixed_converter
- cordic_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Barrel Shifter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
