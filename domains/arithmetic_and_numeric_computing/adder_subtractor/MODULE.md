# Adder Subtractor

## Overview

adder_subtractor performs parameterized addition and subtraction with a documented width, signedness, carry, and overflow contract. It is the base arithmetic primitive that many larger operators depend on.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Even basic arithmetic becomes ambiguous in hardware when signedness, overflow, carry, and latency are not documented. adder_subtractor makes those rules reusable.

## Typical Use Cases

- Build counters, address generators, and delta computations.
- Support arithmetic datapaths that need selectable add or subtract.
- Serve as a core primitive under larger control and DSP operators.

## Interfaces and Signal-Level Behavior

- Inputs usually include operand A, operand B, add or subtract select, and optional carry-in.
- Outputs include result and optionally carry-out, overflow, zero, or sign flags.
- Pipelined wrappers may add valid and fixed latency.

## Parameters and Configuration Knobs

- DATA_WIDTH sets operand width.
- SIGNED_MODE defines interpretation for overflow and sign flags.
- CARRY_IN_EN and CARRY_OUT_EN enable chaining.
- SATURATE_EN replaces wrap with clipping.
- PIPELINE_STAGES sets latency.

## Internal Architecture and Dataflow

The usual design shares one adder and performs subtraction through inversion and carry injection. The important point is that carry-out and signed overflow mean different things and should both be documented when exposed.

## Numeric Format, Clocking, and Timing Assumptions

A given instance should have one stable numeric interpretation. Saturation endpoints must match the documented signedness. Registered variants should define flag timing explicitly.

## Latency, Throughput, and Resource Considerations

Carry chains are usually efficient, but wide flag-rich adders can still become critical. Saturation and flag generation may justify pipelining in very fast designs.

## Verification Strategy

- Check signed overflow and unsigned carry separately.
- Exercise subtraction around zero and minimum negative values.
- Verify saturation behavior if enabled.
- Use exhaustive small-width and randomized large-width testing.

## Integration Notes and Dependencies

adder_subtractor feeds counters, MAC support logic, address generation, and control loops. Stable flag semantics across the library reduce a surprising amount of integration friction.

## Edge Cases, Failure Modes, and Design Risks

- Carry-out is not the same as signed overflow.
- Subtract-path borrow semantics can be misunderstood if not described carefully.
- Saturation options add hidden comparison logic that changes both timing and meaning.

## Related Modules In This Domain

- saturating_adder
- mac_unit
- multiplier
- abs_min_max

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Adder Subtractor module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
