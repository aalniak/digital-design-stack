# Priority Arbiter

## Overview

priority_arbiter selects one requester according to a fixed or configurable precedence order. It is the simplest deterministic arbitration primitive in the library.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Shared resources need a single grant decision, and handwritten priority logic often hides tie-breaking and masking rules. priority_arbiter makes those rules explicit.

## Typical Use Cases

- Give urgent traffic priority over background traffic.
- Choose which requester may access a shared output in a cycle.
- Implement deterministic service ordering in small controllers.

## Interfaces and Signal-Level Behavior

- Inputs generally include request and optional mask vectors.
- Outputs include one-hot grant, encoded winner, and valid.
- Optional hold or accept inputs support multi-cycle ownership.

## Parameters and Configuration Knobs

- NUM_REQUESTERS sets width.
- PRIORITY_ORDER defines fixed precedence.
- ENCODED_OUTPUT_EN enables index output.
- LOCK_ON_ACCEPT preserves the grant during a transaction.
- MASK_EN adds external masking.

## Internal Architecture and Dataflow

The block is usually a priority encoder plus one-hot decode and optional hold state. The most important aspect is that the precedence rule is easy to inspect and verify.

## Clocking, Reset, and Timing Assumptions

All requests are synchronous to the arbitration clock. Reset clears any held grant state. If requests are asynchronous, they must be conditioned elsewhere.

## Latency, Throughput, and Resource Considerations

Fixed-priority selection is usually cheap and fast, though wide vectors can still create a long combinational path. Resource use scales roughly with requester count.

## Verification Strategy

- Verify the highest-priority active request always wins.
- Check masking and hold behavior.
- Exercise simultaneous multi-request cases.
- Confirm one-hot and encoded outputs match exactly.

## Integration Notes and Dependencies

priority_arbiter commonly sits under stream_mux, interrupt logic, and control-plane gateways. It should be chosen intentionally when starvation is acceptable.

## Edge Cases, Failure Modes, and Design Risks

- Fixed priority can starve low-priority clients.
- Wide combinational selection can become a timing hot spot.
- Hold behavior must be clearly separated from simple one-cycle grant behavior.

## Related Modules In This Domain

- round_robin_arbiter
- interrupt_controller
- stream_mux
- stream_demux

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Priority Arbiter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
