# MAC Unit

## Overview

mac_unit performs multiply-accumulate on integer or fixed-point operands and is one of the most important reusable compute blocks in the library. It is the workhorse under filters, dot products, and many control algorithms.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

A multiply alone is rarely enough. Real datapaths need accumulation, preload, clear, widening, and a known latency. mac_unit standardizes those concerns so larger pipelines can build on one arithmetic contract.

## Typical Use Cases

- Implement FIR taps, dot products, and convolution support.
- Accumulate products in matrix or vector operations.
- Support fixed-point control and estimation loops.

## Interfaces and Signal-Level Behavior

- Inputs typically include multiplicand, multiplier, and accumulate or clear control.
- Outputs include accumulated result and often overflow or saturation status.
- Streaming or pipelined wrappers may add valid timing.

## Parameters and Configuration Knobs

- A_WIDTH and B_WIDTH size operands.
- ACC_WIDTH defines accumulation precision.
- SIGNED_MODE controls operand interpretation.
- SATURATE_EN enables clipping instead of wrap.
- PIPELINE_STAGES sets latency.

## Internal Architecture and Dataflow

The typical design widens the product and adds it into an accumulator path, often with optional preload or clear. The crucial documentation point is when the feedback path is available again and what precision the accumulator keeps.

## Numeric Format, Clocking, and Timing Assumptions

Binary-point location and scaling convention must be agreed upon by surrounding logic. If outputs narrow or saturate, that policy must be explicit. Registered variants need deterministic feedback timing.

## Latency, Throughput, and Resource Considerations

DSP blocks usually help, but wide accumulators and feedback timing can still create the critical path. Throughput may be one result per cycle even with multi-cycle latency.

## Verification Strategy

- Compare against a golden model over random signed and unsigned operands.
- Exercise clear, preload, and accumulate sequencing around pipeline latency.
- Verify overflow and saturation at accumulator extremes.
- Run long accumulation sequences to catch compound numeric issues.

## Integration Notes and Dependencies

mac_unit is foundational for filters, matrix math, and custom compute pipelines. Standardizing accumulator width and overflow policy across the library pays off quickly.

## Edge Cases, Failure Modes, and Design Risks

- Accumulator width that is too small silently clips long sums.
- Feedback timing is easy to misunderstand in pipelined implementations.
- Sign-extension mistakes often appear only with negative operands and long runs.

## Related Modules In This Domain

- multiplier
- adder_subtractor
- saturating_adder
- complex_multiplier

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the MAC Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
