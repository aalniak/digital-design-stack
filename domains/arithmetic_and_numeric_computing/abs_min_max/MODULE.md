# Abs Min Max

## Overview

abs_min_max provides absolute value, minimum, and maximum selection under a documented signedness and overflow policy. It is a small but heavily reused arithmetic primitive.

## Domain Context

In the Arithmetic and Numeric Computing domain, modules must expose a precise mathematical contract as well as a clear hardware contract. Width, signedness, latency, rounding, saturation, and special-value handling all matter because these blocks sit under DSP, control, vision, and ML pipelines.

## Problem Solved

These operations show up everywhere, and ad hoc versions often disagree on signedness, tie-breaking, and the corner case of the most negative value. abs_min_max standardizes those choices.

## Typical Use Cases

- Compute magnitudes or peaks in DSP chains.
- Support compare-select logic in pooling or threshold paths.
- Implement clipping or winner selection in small arithmetic pipelines.

## Interfaces and Signal-Level Behavior

- Inputs usually include one or two operands and an operation select or parallel outputs.
- Outputs may include abs, min, max, and optional compare flags.
- The block may be purely combinational or wrapped in a fixed-latency shell.

## Parameters and Configuration Knobs

- DATA_WIDTH sets operand width.
- SIGNED_MODE defines comparison interpretation.
- SATURATE_ABS controls the most-negative-input corner case.
- PIPELINE_STAGES allows retiming.
- PARALLEL_OUTPUTS_EN exposes multiple results at once.

## Internal Architecture and Dataflow

The block is built from compare and optional negation logic. The most important contract question is what absolute value does with the most negative two's-complement input.

## Numeric Format, Clocking, and Timing Assumptions

Numeric interpretation must be explicit and stable for a given instance. Registered variants need a documented latency and reset story if valid signals exist.

## Latency, Throughput, and Resource Considerations

The path is typically short, but wide compare and negate logic can still benefit from pipelining in aggressive clocks. Resource use is low.

## Verification Strategy

- Check signed and unsigned behavior separately.
- Exercise the most negative value through the abs path.
- Verify tie behavior for equal operands.
- Compare pipelined and unpipelined configurations against one golden model.

## Integration Notes and Dependencies

abs_min_max often appears under thresholding, pooling, sorting, and AGC-style logic. A shared overflow and tie policy across the library reduces surprises.

## Edge Cases, Failure Modes, and Design Risks

- The absolute-value corner case is the main functional trap.
- Signedness mismatches can remain hidden until negative values appear.
- Latency changes are easy to overlook because the operator seems simple.

## Related Modules In This Domain

- adder_subtractor
- comparator_tree
- saturating_adder
- popcount_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Abs Min Max module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
