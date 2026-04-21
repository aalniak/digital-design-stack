# Semaphore Block

## Overview

semaphore_block provides a small hardware-managed mutual exclusion or token-ownership primitive for coordinating access among software agents, masters, or subsystems. It is the bounded synchronization primitive of the control plane.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

Shared resources often need simple lock or token semantics without full software-managed spin protocols scattered everywhere. semaphore_block centralizes acquisition, release, and visibility of that ownership state.

## Typical Use Cases

- Protect a shared register set or scratchpad region between several agents.
- Implement a doorbell or token-based work claim mechanism.
- Coordinate software and hardware access to a non-coherent shared resource.

## Interfaces and Signal-Level Behavior

- Inputs commonly include acquire, release, test, and optional owner ID or key fields.
- Outputs include grant, busy, owner state, and optional contention or timeout status.
- A control-plane wrapper may expose the primitive through CSR or bus transactions.

## Parameters and Configuration Knobs

- NUM_SEMAPHORES sets how many independent locks exist.
- OWNER_ID_WIDTH sizes optional ownership tagging.
- FAIRNESS_MODE selects first-come or simpler fixed behavior if queued acquisition is supported.
- TIMEOUT_EN enables contention watchdog or stale-lock detection.
- AUTO_RELEASE_EN defines behavior on reset or fault of an owner.

## Internal Architecture and Dataflow

At minimum, a semaphore block stores ownership state and resolves acquisition requests atomically. More capable versions also track owner identity, contention counts, or timeout information. The crucial contract is what constitutes an atomic acquire and what guarantees exist when several requesters contend simultaneously.

## Clocking, Reset, and Timing Assumptions

Callers must know whether the block is a pure test-and-set primitive, a queued semaphore, or a simple lock bit. Reset policy is especially important because lock ownership after fault or warm reset can be system critical.

## Latency, Throughput, and Resource Considerations

Semaphores are low-throughput primitives, so determinism matters more than bandwidth. Hardware cost is small unless fairness queues or timeout tracking are added.

## Verification Strategy

- Exercise simultaneous acquisition attempts.
- Check release by owner and illegal release by non-owner if owner tracking exists.
- Verify reset and auto-release policy.
- Stress contention with long hold times and optional timeouts.

## Integration Notes and Dependencies

semaphore_block often complements mailbox and CSR logic when several masters share a resource but full cache coherence is absent. It should be used where hardware-level arbitration is simpler than software-only conventions.

## Edge Cases, Failure Modes, and Design Risks

- Lock ownership semantics that are not explicit create deadlock or data-corruption risk immediately.
- Reset behavior on held semaphores is a major system policy point.
- Fairness assumptions can differ sharply between software expectations and hardware reality.

## Related Modules In This Domain

- mailbox_block
- csr_bank
- transaction_tracker
- interrupt_aggregator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Semaphore Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
