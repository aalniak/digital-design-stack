# Burst Adapter

## Overview

burst_adapter converts between differing burst semantics, lengths, or alignment constraints while preserving payload order and sideband meaning. It is the transaction-shaping primitive between mismatched initiators and targets.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Adjacent interfaces often disagree on legal burst lengths, alignment, wrapping behavior, or boundary rules. A reusable burst_adapter keeps those translation rules in one place rather than scattering them across masters and slaves.

## Typical Use Cases

- Adapt a DMA engine to a memory target with stricter burst limits.
- Split or merge transactions to satisfy alignment or page-boundary rules.
- Convert between fixed, incrementing, or constrained burst styles on different fabrics.

## Interfaces and Signal-Level Behavior

- Inputs usually include address, burst length, beat size, payload, and request qualifiers.
- Outputs present translated bursts toward the target side plus any required status or completion mapping.
- The module may also track response association when one source burst becomes several target bursts.

## Parameters and Configuration Knobs

- MAX_OUT_BURST defines the largest supported target burst.
- ALIGNMENT_POLICY selects how misaligned starts are handled.
- WRAP_SUPPORT_EN indicates whether wrapping bursts are legal.
- MERGE_POLICY defines when adjacent beats may be combined.
- RESPONSE_TRACKING_EN enables source-to-target completion mapping.

## Internal Architecture and Dataflow

A burst adapter typically contains transaction decomposition logic, beat counters, address generators, and small bookkeeping structures that reconnect target responses to the source request context. The most important design decision is whether it preserves simple one-request-in-flight behavior or supports several translated sub-bursts concurrently.

## Clocking, Reset, and Timing Assumptions

Addressing and byte-lane semantics must match the surrounding bus or local protocol. If the target side imposes page or row boundaries, the module should document whether it enforces them proactively or expects a higher layer to do so.

## Latency, Throughput, and Resource Considerations

Burst adaptation can improve system compatibility at the cost of added latency and bookkeeping. Throughput depends on how much concurrency the adapter allows and whether split bursts can overlap on the target side.

## Verification Strategy

- Exercise aligned and misaligned bursts of varying length.
- Check split and merged response accounting.
- Stress corner cases at page, row, or configured boundary limits.
- Compare translated traffic against a source-target transaction model.

## Integration Notes and Dependencies

burst_adapter commonly sits between DMA engines, cache controllers, and external memory front ends. It is most useful when the rest of the system can stay simple and rely on one explicit translation point.

## Edge Cases, Failure Modes, and Design Risks

- Translated responses can be misattributed if bookkeeping is incomplete.
- Boundary handling is a classic source of off-by-one bugs.
- Excessive serialization can erase the bandwidth benefit of burst transfers.

## Related Modules In This Domain

- dma_engine
- scatter_gather_dma
- cache_controller
- address_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Burst Adapter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
