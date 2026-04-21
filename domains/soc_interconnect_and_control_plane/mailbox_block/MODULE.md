# Mailbox Block

## Overview

mailbox_block provides a small shared communication primitive for passing commands, events, or short payloads between software agents, processors, or hardware subsystems. It is the lightweight message-exchange primitive of the control plane.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

Not every coordination need warrants a full shared-memory queue or bus protocol. mailbox_block offers a bounded, explicit mechanism for ownership transfer, notification, and short message exchange.

## Typical Use Cases

- Pass commands between cores or between software and hardware.
- Implement doorbell-style work submission with payload.
- Exchange status or events between isolated subsystems with minimal shared state.

## Interfaces and Signal-Level Behavior

- Inputs often include write message, read consume, clear, and optional interrupt or doorbell control.
- Outputs include message data, empty or full state, and optional notification signals.
- Some variants expose separate producer and consumer views to simplify ownership rules.

## Parameters and Configuration Knobs

- DATA_WIDTH sets payload size.
- DEPTH defines whether the mailbox is single-entry or queue-like.
- INTERRUPT_EN enables notify-on-write or notify-on-read behavior.
- OVERWRITE_POLICY defines what happens when a new message arrives to a full mailbox.
- DIRECTION_MODE selects uni- or bi-directional mailbox style.

## Internal Architecture and Dataflow

A mailbox block is often a tiny storage structure plus ownership and notification logic. The key behavioral question is whether it is a strict one-message-at-a-time exchange, a small queue, or a dual-ended control primitive with explicit producer and consumer roles.

## Clocking, Reset, and Timing Assumptions

The mailbox is not a substitute for high-throughput streaming or bulk shared memory. Callers must know whether messages are overwritten, blocked, or queued when capacity is exhausted. Reset should define whether any stale payload is considered valid.

## Latency, Throughput, and Resource Considerations

Throughput is intentionally modest. The value lies in deterministic coordination and low hardware cost. Notification timing and ownership transfer semantics matter more than bandwidth.

## Verification Strategy

- Check empty, full, and overwrite or backpressure policy.
- Exercise notification generation and clear behavior.
- Verify ownership transfer between producer and consumer views.
- Stress reset and simultaneous producer-consumer actions.

## Integration Notes and Dependencies

mailbox_block commonly pairs with CSR banks, interrupt aggregation, and software-facing endpoints. It is useful where a bounded command or status path is preferable to exposing a shared memory region.

## Edge Cases, Failure Modes, and Design Risks

- Mailbox semantics that are too ambiguous invite software misuse.
- Single-entry designs can lose messages if overwrite or block policy is not explicit.
- Notification timing should match the actual ownership model or software races will follow.

## Related Modules In This Domain

- csr_bank
- interrupt_aggregator
- semaphore_block
- debug_bridge

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Mailbox Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
