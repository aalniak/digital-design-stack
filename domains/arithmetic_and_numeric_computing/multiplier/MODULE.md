# Multiplier

## Overview

multiplier computes the product of two operands and exposes a precise contract for sign handling, width growth, latency, and optional narrowing or rounding. It is the base product primitive for many larger arithmetic blocks.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

Even simple multiplication needs clear answers about signedness, output width, and what part of the product is returned. multiplier gives the stack one reusable answer.

## Typical Use Cases

- Provide standalone products where accumulation is not needed.
- Feed MAC, complex multiply, or scaling pipelines.
- Implement address scaling or coefficient application.

## Interfaces and Signal-Level Behavior

- Inputs usually include operand A and operand B plus optional valid.
- Outputs provide full product or selected slices plus optional valid.
- Some variants expose high-part, low-part, or rounded outputs.

## Parameters and Configuration Knobs

- A_WIDTH and B_WIDTH size operands.
- SIGNED_MODE defines numeric interpretation.
- OUTPUT_MODE selects full, truncated, high-part, or rounded product.
- ROUND_MODE controls narrowing policy.
- PIPELINE_STAGES sets latency.

## Internal Architecture and Dataflow

Implementations may map to DSP blocks or synthesized partial-product logic, but the user-facing contract should stay stable. Narrowed outputs must state exactly which bits are kept and how rounding is applied.

## Numeric Format, Clocking, and Timing Assumptions

Product growth follows the documented width and signedness rules. Registered variants must keep output timing fixed. Any returned high-part or truncated result implies a scaling contract that consumers must understand.

## Latency, Throughput, and Resource Considerations

Multipliers are often efficient on modern hardware, but width, signedness support, and optional rounding still influence timing and resource use.

## Verification Strategy

- Compare against a software model over random operands.
- Exercise signed-negative combinations carefully.
- Verify narrowed output modes and rounding behavior.
- Check valid alignment and fixed latency in pipelined forms.

## Integration Notes and Dependencies

multiplier underlies MACs, complex arithmetic, and many approximate-divide schemes. Stable narrowing and sign semantics help those higher-level blocks compose correctly.

## Edge Cases, Failure Modes, and Design Risks

- Returning only part of the product without clear scaling guidance causes downstream confusion.
- Minimum-negative signed cases deserve explicit testing.
- Latency changes can silently break feedback scheduling upstream.

## Related Modules In This Domain

- mac_unit
- complex_multiplier
- adder_subtractor
- reciprocal_approximation

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Multiplier module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
