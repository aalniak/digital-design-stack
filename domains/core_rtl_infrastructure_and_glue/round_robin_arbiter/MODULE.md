# Round Robin Arbiter

## Overview

round_robin_arbiter selects among competing requesters while rotating priority after each accepted grant so access is shared fairly over time. It is the fairness-oriented arbitration primitive in the library.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Fixed-priority arbitration is simple but can starve low-priority clients under sustained load. round_robin_arbiter solves that by remembering where service last occurred and beginning the next search after that point.

## Typical Use Cases

- Share a memory or stream output fairly among peers.
- Schedule several packet or DMA queues without starvation.
- Provide balanced access in a multiplexed datapath.

## Interfaces and Signal-Level Behavior

- Inputs usually include request and optional mask vectors.
- Outputs include grant one-hot, winner index, and valid.
- An accept or hold input often determines when the rotation pointer actually advances.

## Parameters and Configuration Knobs

- NUM_REQUESTERS sets width.
- HOLD_UNTIL_ACCEPT defines when the pointer advances.
- ENCODED_OUTPUT_EN enables winner index.
- MASK_EN adds per-cycle masking.
- PARK_MODE defines idle grant behavior.

## Internal Architecture and Dataflow

The usual design stores a rotating priority pointer and scans requests from that location, wrapping as needed. Correct pointer update on real acceptance is the detail that preserves fairness without wasting bandwidth.

## Clocking, Reset, and Timing Assumptions

All requests are synchronous to the arbitration clock. Reset initializes the rotation pointer. If packet atomicity matters, the arbiter must cooperate with a hold-until-end policy elsewhere or internally.

## Latency, Throughput, and Resource Considerations

The block can usually produce one arbitration result per cycle, though wide request vectors may need hierarchy or pipelining. Cost is somewhat higher than fixed priority because of wraparound selection and pointer state.

## Verification Strategy

- Stress long random request patterns and look for starvation.
- Verify pointer movement only on the documented accept condition.
- Exercise wraparound winner selection.
- Compare the grant sequence against a software model.

## Integration Notes and Dependencies

round_robin_arbiter is a natural companion to stream_mux, packet scheduling, and shared compute resources. It should be chosen when fairness is part of the system contract, not only when starvation happens to be noticed.

## Edge Cases, Failure Modes, and Design Risks

- If the pointer advances on the wrong event, fairness collapses silently.
- Acceptance semantics must be precise or simulation and silicon may rotate differently.
- Wide fan-in can create a significant selection path.

## Related Modules In This Domain

- priority_arbiter
- stream_mux
- packet_fifo
- interrupt_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Round Robin Arbiter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
