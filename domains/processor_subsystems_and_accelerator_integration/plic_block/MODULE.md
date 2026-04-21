# PLIC Block

## Overview

PLIC Block prioritizes, masks, and routes external interrupt sources to processor harts using a memory-mapped claim and complete model. It provides centralized external-interrupt control for multi-source processor subsystems.

## Domain Context

A PLIC-style interrupt controller provides prioritized external interrupt routing to one or more processor harts. In this domain it is the software-visible aggregation layer between many platform interrupt sources and the hart-local interrupt inputs.

## Problem Solved

As platforms grow, raw interrupt lines become unmanageable. A dedicated PLIC block makes source priority, target routing, and software interaction consistent and scalable.

## Typical Use Cases

- Aggregating peripheral and accelerator interrupts for one or more harts.
- Providing software claim and complete semantics for external interrupts.
- Supporting OS and firmware interrupt initialization on a RISC-V-like platform.
- Managing prioritized delivery of many asynchronous platform events.

## Interfaces and Signal-Level Behavior

- Inputs include external interrupt source lines and memory-mapped register accesses.
- Outputs provide per-hart external interrupt indications and source identification via claim interface.
- Control interfaces are the memory-mapped priority, enable, threshold, claim, and complete registers.
- Status signals may expose pending source state and target interrupt-active status.

## Parameters and Configuration Knobs

- Number of interrupt sources and harts.
- Priority width and pending-bit representation.
- Memory-map profile and optional source grouping.
- Optional gateway or edge-versus-level handling support.

## Internal Architecture and Dataflow

The block usually contains pending storage, priority comparison, per-target enables and thresholds, and claim-complete state machines. The architectural contract should document level and edge behavior and the exact claim-complete semantics, because software interrupt service flow depends on them precisely.

## Clocking, Reset, and Timing Assumptions

The module assumes external source lines are synchronized or gateway-conditioned as required. Reset clears enables and pending state according to platform policy. If sources are level triggered, the expectation around reassertion after complete should be explicit.

## Latency, Throughput, and Resource Considerations

Area scales with source count and hart count. Latency to assert an interrupt should be short and deterministic, but the dominant concern is software-visible correctness of pending and claim behavior rather than speed alone.

## Verification Strategy

- Verify priority, threshold, and routing behavior across several sources and harts.
- Stress edge and level source semantics if both are supported.
- Check claim and complete sequencing, especially with repeated source assertion.
- Run software-level interrupt handling tests on the integrated platform.

## Integration Notes and Dependencies

PLIC Block connects the broader SoC interrupt fabric to the core wrapper and works alongside CLINT for local timer and software interrupts. It should align with the firmware-visible memory map and source numbering scheme.

## Edge Cases, Failure Modes, and Design Risks

- A source-numbering mismatch can make firmware service the wrong peripheral.
- Level-versus-edge ambiguity is a common source of repeated or missing interrupts.
- Threshold or enable reset defaults that are not documented clearly can stall platform bring-up.

## Related Modules In This Domain

- clint_block
- riscv_core_wrapper
- multicore_mailbox
- accelerator_dispatcher

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PLIC Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
