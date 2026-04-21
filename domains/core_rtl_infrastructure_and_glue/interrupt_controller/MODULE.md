# Interrupt Controller

## Overview

interrupt_controller aggregates event sources, applies masks and priority, and presents a controlled service interface to software or supervisory logic. It is the control-plane fan-in point for asynchronous and synchronous events.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

A system with many raw service events becomes unmanageable without one place that owns pending-state, enable-mask, and selection rules. interrupt_controller provides that ownership.

## Typical Use Cases

- Collect faults, completions, and threshold events into one processor interface.
- Prioritize urgent service sources over background work.
- Expose pending and active status in a software-friendly form.

## Interfaces and Signal-Level Behavior

- Inputs are source events plus mask, clear, and configuration controls.
- Outputs include one or more interrupt requests and often a selected source ID.
- Readable state usually includes raw, enabled, pending, and active views.

## Parameters and Configuration Knobs

- NUM_SOURCES sets input count.
- NUM_OUTPUTS or TARGETS sets fan-out.
- LATCH_MODE defines edge or level pending behavior.
- VECTOR_MODE enables source ID outputs.
- PRIORITY_LEVELS or fixed ordering defines service precedence.

## Internal Architecture and Dataflow

The controller typically has source conditioning, pending-state storage, mask logic, and a selector. The design should separate raw event observation from pending-state policy so behavior is easy to reason about.

## Clocking, Reset, and Timing Assumptions

Events should already be safe in the local control clock domain. Reset should establish a known pending and enable state. Level sources need a defined re-service policy after acknowledge.

## Latency, Throughput, and Resource Considerations

The priority-selection tree is usually the critical path. Large controllers may need hierarchical grouping. Throughput is measured by how quickly new events can be latched while others are being serviced.

## Verification Strategy

- Check pulse and level source handling separately.
- Exercise simultaneous events and verify the documented priority.
- Verify clear or acknowledge races do not lose events.
- Scoreboard vector outputs against pending-state.

## Integration Notes and Dependencies

interrupt_controller commonly consumes timer expirations, event counters, and fault monitors. Stable bit allocation and source naming across the stack improve software portability.

## Edge Cases, Failure Modes, and Design Risks

- Mixing pulse and level semantics without clear conditioning leads to missed or repeated service.
- Priority trees can hide timing problems.
- Acknowledge policy must be explicit or events will be lost under load.

## Related Modules In This Domain

- priority_arbiter
- round_robin_arbiter
- timer_block
- event_counter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Interrupt Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
