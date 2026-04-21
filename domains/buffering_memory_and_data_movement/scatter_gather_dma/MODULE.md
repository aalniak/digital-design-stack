# Scatter Gather DMA

## Overview

scatter_gather_dma extends basic DMA behavior to move data between many non-contiguous regions under descriptor control. It is the descriptor-rich data-movement primitive for complex memory layouts.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Real systems rarely move only one contiguous buffer at a time. Scatter-gather support is needed for fragmented memory, packet chains, and software-managed rings. scatter_gather_dma makes that complexity explicit.

## Typical Use Cases

- Move packet chains or fragmented buffers without CPU copying.
- Gather many disjoint source regions into one output stream or scatter one stream into several destinations.
- Implement queue-driven storage and networking data movement.

## Interfaces and Signal-Level Behavior

- Control inputs typically come from descriptor_fetcher or direct descriptor injection.
- Data interfaces drive memory reads and writes or stream sinks and sources.
- Status outputs include descriptor completion, partial-progress reporting, and fault context.

## Parameters and Configuration Knobs

- MAX_SEGMENTS defines supported descriptor-chain depth or outstanding fragment count.
- ADDRESS_WIDTH and DATA_WIDTH size the transfer path.
- MERGE_SMALL_SEGMENTS_EN enables optimization of tiny adjacent segments.
- ERROR_RECOVERY_MODE defines stop, skip, or report-and-continue behavior.
- OUTSTANDING_TXNS sets concurrency.

## Internal Architecture and Dataflow

A scatter-gather DMA engine layers descriptor traversal and segment bookkeeping on top of a basic transfer engine. The difficult parts are preserving source-to-destination mapping across many fragments and defining what completion means when a fault happens mid-chain.

## Clocking, Reset, and Timing Assumptions

Descriptor format and ownership rules must be documented clearly. Reset should define how partially executed chains are invalidated or resumed. Callers must know whether segment order is always preserved and whether zero-length segments are legal.

## Latency, Throughput, and Resource Considerations

This block can greatly reduce CPU overhead, but throughput depends on descriptor efficiency, segment granularity, and how many fragments can overlap in flight. Hardware cost rises with bookkeeping and response association complexity.

## Verification Strategy

- Exercise chains with many short and long segments.
- Verify zero-length, overlapping, and boundary-crossing descriptors.
- Inject faults in the middle of a chain and confirm partial-completion policy.
- Compare moved data and completion records against a descriptor-level software model.

## Integration Notes and Dependencies

scatter_gather_dma usually sits next to descriptor_fetcher, burst_adapter, and memory or network front ends. It should state clearly whether it is a general segmented copy engine or optimized for one traffic style such as packet chains.

## Edge Cases, Failure Modes, and Design Risks

- Partial-completion semantics are a major integration hazard.
- Descriptor traversal bugs can silently skip or repeat segments.
- Small-fragment overhead can dominate throughput if the engine is not designed with realistic workloads in mind.

## Related Modules In This Domain

- dma_engine
- descriptor_fetcher
- burst_adapter
- cache_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Scatter Gather DMA module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
