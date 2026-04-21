# Interrupt Aggregator

## Overview

interrupt_aggregator collects many interrupt-like sources and compresses or routes them into a smaller set of control-plane signals suitable for a processor, monitor, or higher-level interrupt controller. It is the fan-in glue block for scalable event reporting.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

Large systems often have more event sources than the next-level handler can accept directly. interrupt_aggregator centralizes grouping, masking, and hierarchical reporting without forcing every source to know the global interrupt topology.

## Typical Use Cases

- Combine several local fault and service sources into one upstream interrupt line.
- Build hierarchical interrupt trees across subsystems.
- Preserve summary status while reducing top-level wire count.

## Interfaces and Signal-Level Behavior

- Inputs are usually raw or conditioned interrupt source lines plus optional masks.
- Outputs may include grouped interrupt lines, summary bits, and optional encoded cause or group identifiers.
- Status may expose per-group pending views for software or higher-level logic.

## Parameters and Configuration Knobs

- NUM_SOURCES sets source count.
- NUM_GROUPS defines the number of output summaries.
- MASK_EN enables per-source masking.
- CAUSE_EN enables encoded or summary-cause reporting.
- LATCH_MODE defines whether grouped status is level-based or latched.

## Internal Architecture and Dataflow

An aggregator usually OR-reduces or otherwise groups sources according to a configured map, optionally preserving some cause information. Compared with a full interrupt controller, it owns less policy and more topology reduction.

## Clocking, Reset, and Timing Assumptions

Source semantics must be clear before aggregation; mixing pulses and levels without conditioning elsewhere can create ambiguous grouped behavior. Reset should establish a known empty pending state if latching is used.

## Latency, Throughput, and Resource Considerations

Aggregation is usually low cost, though large source counts may still create wide reduction trees. The real value is structural simplicity at the top level rather than raw throughput.

## Verification Strategy

- Verify each source appears in the intended group.
- Check masking and grouped pending behavior.
- Exercise simultaneous assertion from many groups.
- Confirm encoded cause or summary outputs match the grouped policy.

## Integration Notes and Dependencies

interrupt_aggregator commonly sits below an interrupt_controller or processor interrupt input. It is especially useful when subsystems want local source richness but the top-level architecture wants fewer incoming lines.

## Edge Cases, Failure Modes, and Design Risks

- Grouping can hide important source detail if software cannot recover the root cause elsewhere.
- Latched versus level semantics must be explicit at the group output.
- Wide reduction logic can create timing issues if aggregation is placed too late in the hierarchy.

## Related Modules In This Domain

- interrupt_controller
- event_counter
- pulse_synchronizer
- csr_bank

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Interrupt Aggregator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
