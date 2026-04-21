# DMA Engine

## Overview

dma_engine moves data between address spaces or interfaces with minimal CPU intervention while exposing a clear contract for descriptors, alignment, bursts, errors, and completion. It is one of the central data-movement primitives in the stack.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Data movement is easy to underestimate. Address generation, burst shaping, partial-line handling, error recovery, and completion reporting all need to work together. dma_engine makes that behavior explicit and reusable.

## Typical Use Cases

- Copy data between memory regions.
- Move sampled data into storage or feed streaming consumers from memory.
- Offload repetitive transfers that software should only configure and monitor.

## Interfaces and Signal-Level Behavior

- Control inputs usually include start or descriptor data, source and destination addresses, length, and mode.
- Data-side outputs may drive memory reads and writes or a streaming source or sink.
- Status outputs often include busy, done, bytes transferred, and fault indications.

## Parameters and Configuration Knobs

- ADDRESS_WIDTH and DATA_WIDTH size addressing and datapath.
- MAX_BURST defines transfer granularity toward memory.
- ALIGNMENT_POLICY defines handling of unaligned endpoints.
- INTERRUPT_EN exposes completion or error service signals.
- OUTSTANDING_TXNS sets how many requests may remain in flight.

## Internal Architecture and Dataflow

A DMA engine normally includes source and destination address generators, length counters, read and write issue logic, response tracking, and completion or fault state. The main contract decisions are whether reads and writes may overlap, how partial transfers are handled, and how completion is defined after faults.

## Clocking, Reset, and Timing Assumptions

Address-space semantics and access permissions must be defined by the surrounding system. Reset should cancel or invalidate in-flight state in a deterministic way. If descriptors are used, the descriptor parser should define the configuration boundary clearly.

## Latency, Throughput, and Resource Considerations

DMA usefulness depends on sustained bandwidth, outstanding transaction depth, and how effectively burst opportunities are exploited. Hardware cost rises with concurrency, buffering, and data-width conversion support.

## Verification Strategy

- Run copy operations across aligned and misaligned ranges.
- Exercise zero-length, short, and very large transfers.
- Inject read, write, and response faults and verify recovery policy.
- Compare transferred data and completion accounting against a memory model.

## Integration Notes and Dependencies

dma_engine sits naturally next to descriptor_fetcher, burst_adapter, caches, and external memory interfaces. Its contract should specify exactly when software may reuse or free a source or destination region.

## Edge Cases, Failure Modes, and Design Risks

- Fault handling and partial completion semantics are often underspecified.
- Outstanding response bookkeeping can silently corrupt transfers if wrong.
- Alignment corner cases appear late if only ideal bursts are tested.

## Related Modules In This Domain

- descriptor_fetcher
- scatter_gather_dma
- burst_adapter
- cache_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DMA Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
