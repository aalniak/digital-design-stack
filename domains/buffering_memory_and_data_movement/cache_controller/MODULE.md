# Cache Controller

## Overview

cache_controller arbitrates access to cached data, detects hits and misses, manages fills and evictions, and enforces a documented coherence or consistency contract at the cache boundary. It is the policy-rich storage block of the memory-movement domain.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Caching is useful only when hit behavior, miss handling, replacement, write policy, and line state are explicit. cache_controller packages those policies into one reusable component rather than leaving every subsystem to invent its own partial cache semantics.

## Typical Use Cases

- Provide low-latency access to a slower backing memory.
- Hide burst-oriented refill behavior from a narrow local client.
- Stage working sets for processors, accelerators, or DMA-assisted pipelines.

## Interfaces and Signal-Level Behavior

- Client-side inputs typically include address, read or write intent, byte enables, and request qualifiers.
- Memory-side outputs include line fills, evictions, and burst transfers toward backing storage.
- Status may expose hit, miss, eviction, dirty, invalidate, or flush progress.

## Parameters and Configuration Knobs

- LINE_SIZE sets cache line width.
- NUM_SETS and NUM_WAYS define organization.
- WRITE_POLICY selects write-back or write-through style.
- REPLACEMENT_POLICY chooses direct mapped, round-robin, LRU-like, or simpler eviction behavior.
- COHERENCY_MODE documents whether the cache is private, software-managed, or externally coherent.

## Internal Architecture and Dataflow

A cache controller usually contains tag arrays, valid and dirty state, hit-detect logic, refill and eviction state machines, and a path for local client requests. The design is only reusable if replacement, refill ordering, and flush or invalidate behavior are surfaced clearly in the contract.

## Clocking, Reset, and Timing Assumptions

The caller must know whether the cache is coherent with any other agent, and what actions software or hardware must take on shared-memory boundaries. Reset should define whether all lines start invalid and how any in-flight miss state is cleared.

## Latency, Throughput, and Resource Considerations

Hit latency, miss penalty, and refill concurrency dominate usefulness. Hardware cost rises quickly with associativity, line size, and dirty-state management. Timing often centers on tag compare and hit-data selection.

## Verification Strategy

- Check hit and miss behavior across cold, warm, and conflict-heavy access patterns.
- Exercise eviction, dirty writeback, and partial writes.
- Verify flush, invalidate, and reset handling.
- Use a reference memory model to confirm consistency across long mixed traffic.

## Integration Notes and Dependencies

cache_controller usually sits between a narrow client-facing port and a wider or slower memory system, often near burst_adapter and scratchpad-like local structures. Coherence assumptions must be documented loudly and early.

## Edge Cases, Failure Modes, and Design Risks

- Coherence or consistency ambiguity is the dominant system risk.
- Eviction and partial-write behavior often hide bugs until long random runs.
- If refill and client pipelines are insufficiently separated, miss handling can deadlock or starve.

## Related Modules In This Domain

- burst_adapter
- dma_engine
- scratchpad_controller
- sp_ram_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Cache Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
