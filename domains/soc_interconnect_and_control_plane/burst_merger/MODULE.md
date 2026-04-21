# Burst Merger

## Overview

burst_merger combines adjacent or compatible smaller transactions into a larger burst when the downstream interface benefits from wider transfer granularity. It is an optimization-oriented shaping block for memory traffic.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

Local clients often issue many short or fragmented transfers even when the target fabric performs best with longer bursts. burst_merger consolidates those opportunities into fewer, larger transactions under a documented compatibility rule.

## Typical Use Cases

- Merge consecutive single-beat transfers into longer memory bursts.
- Improve memory efficiency for software-like control traffic that happens to be adjacent.
- Reduce protocol overhead on a downstream interconnect or memory controller.

## Interfaces and Signal-Level Behavior

- Inputs usually include address, beat size, write data or read intent, and transaction qualifiers.
- Outputs emit merged burst descriptors and associated data streams.
- Status may expose why candidate transactions were not merged, such as boundary or attribute mismatch.

## Parameters and Configuration Knobs

- MAX_MERGED_BURST sets the longest generated burst.
- MERGE_WINDOW defines how many pending requests may be examined together.
- ATTRIBUTE_MATCH_MODE defines which sidebands must match before merging.
- BOUNDARY_POLICY defines page or region boundaries that cannot be crossed.
- LATENCY_BUDGET limits how long the merger may wait for future adjacent requests.

## Internal Architecture and Dataflow

The merger usually buffers a small number of incoming requests, checks adjacency and attribute compatibility, and either extends the current burst or flushes it downstream. The most important design balance is between merge quality and added latency or buffering complexity.

## Clocking, Reset, and Timing Assumptions

The block should document whether merged responses are later split back to the original requester granularity or whether the local side already speaks in merged units. Ordering and side-effect safety matter greatly; not all transactions may legally merge.

## Latency, Throughput, and Resource Considerations

A good merger improves effective bandwidth and reduces command overhead, but it can also add front-end latency and buffering. Resource cost depends on how much look-ahead and request metadata are tracked.

## Verification Strategy

- Check merge eligibility for adjacent and nearly adjacent requests.
- Exercise boundary conditions such as page or region crossings.
- Verify response mapping when one merged burst corresponds to several source requests.
- Confirm side-effecting or non-mergeable transactions are passed through correctly.

## Integration Notes and Dependencies

burst_merger pairs naturally with burst_splitter, DMA, and AXI4 masters or memory schedulers. It should be deployed only where the local traffic pattern and target interface truly benefit from consolidation.

## Edge Cases, Failure Modes, and Design Risks

- Merging writes with side effects or ordering-sensitive semantics can be illegal.
- Latency spent waiting for future merge opportunities may harm real-time behavior.
- Completion accounting can become ambiguous if the local side still thinks in original request units.

## Related Modules In This Domain

- burst_splitter
- burst_adapter
- axi4_master
- transaction_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Burst Merger module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
