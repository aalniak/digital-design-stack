# Multicore Mailbox

## Overview

Multicore Mailbox provides message slots, doorbells, or shared control registers for communication between processor harts or tightly integrated control agents. It offers a simple inter-agent coordination mechanism inside the subsystem.

## Domain Context

A multicore mailbox is the lightweight message or doorbell path between harts or between a host processor and an accelerator-side control core. In this domain it supports coordination without requiring heavy shared-memory protocols for every interaction.

## Problem Solved

Multicore systems need a reliable way to signal events and exchange small control payloads without constantly polling large memory regions. A dedicated mailbox makes message semantics, interrupt behavior, and ownership explicit.

## Typical Use Cases

- Signaling work or events between harts.
- Passing small commands between a CPU and an accelerator management core.
- Supporting bring-up and low-overhead runtime coordination.
- Providing software-controlled doorbells for simple multicore synchronization.

## Interfaces and Signal-Level Behavior

- Inputs include writes from local or remote agents, read requests, and optional interrupt-acknowledge controls.
- Outputs provide message data, status flags such as empty or full, and optional interrupt or doorbell signals.
- Control interfaces configure mailbox depth, target routing, and interrupt generation policy.
- Status signals may expose mailbox_full, mailbox_empty, and overrun conditions.

## Parameters and Configuration Knobs

- Number of mailbox channels and slot width.
- Queue depth versus single-slot behavior.
- Interrupt generation and routing options.
- Per-channel ownership or access-control support.

## Internal Architecture and Dataflow

The mailbox generally consists of registers or small FIFOs, status bits, and optional interrupt-generation logic. The contract should define whether writes overwrite, queue, or are rejected when full, because software coordination patterns depend on that decision.

## Clocking, Reset, and Timing Assumptions

The module assumes participating agents share a coherent view of the mailbox address map and interrupt policy. Reset should define whether pending messages are cleared or retained. If several clocks or domains use the mailbox, CDC handling and write-order expectations should be explicit.

## Latency, Throughput, and Resource Considerations

Area is small and latency is low. The key tradeoff is between minimalism and enough buffering or routing flexibility to prevent message loss in bursty coordination patterns. It is a control-plane primitive, not a bulk-data path.

## Verification Strategy

- Verify send, receive, full, and empty behavior for each supported mailbox mode.
- Stress simultaneous access from several harts or agents.
- Check interrupt generation and clear semantics.
- Run representative software synchronization flows on the integrated subsystem.

## Integration Notes and Dependencies

Multicore Mailbox works alongside CLINT software interrupts, Accelerator Dispatcher, and firmware coordination logic. It should align with OS or runtime assumptions about inter-hart messaging and wakeup behavior.

## Edge Cases, Failure Modes, and Design Risks

- Overwrite-versus-reject semantics that are unclear can create hard-to-debug lost-message bugs.
- If interrupts and message state are not kept coherent, software may service stale or phantom mailbox events.
- CDC assumptions between agents are often underestimated in simple mailbox designs.

## Related Modules In This Domain

- clint_block
- plic_block
- accelerator_dispatcher
- atomic_semaphore_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Multicore Mailbox module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
