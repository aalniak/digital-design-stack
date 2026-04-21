# Bank Interleaver

## Overview

bank_interleaver distributes traffic across several memory or buffer banks according to an interleaving rule that improves bandwidth, reduces hot spots, or aligns accesses to downstream architecture. It is the placement and striping primitive of the memory-movement layer.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Without a disciplined interleaving block, multi-bank memory systems accumulate one-off address striping rules, uneven utilization, and hard-to-debug ordering behavior. bank_interleaver centralizes bank-selection and lane-mapping policy.

## Typical Use Cases

- Stripe a linear address stream across SRAM or BRAM banks.
- Balance burst traffic across several local buffers.
- Match logical words to a banked memory architecture used by a compute pipeline.

## Interfaces and Signal-Level Behavior

- Inputs usually include address or beat index, payload data, write and read qualifiers, and optional burst metadata.
- Outputs include bank select, per-bank address, and routed payload or control signals.
- Status may expose bank conflicts, stall conditions, or reorder restrictions.

## Parameters and Configuration Knobs

- NUM_BANKS sets the number of target banks.
- INTERLEAVE_GRANULARITY defines the address stride per bank.
- ADDRESS_MAP_MODE selects simple round-robin striping or custom bank mapping.
- CONFLICT_POLICY chooses stall, retry, or serialized service when two accesses target one bank.
- PRESERVE_ORDER_EN documents ordering guarantees across banks.

## Internal Architecture and Dataflow

The module usually derives bank index and bank-local address from the incoming logical address or beat count, then routes requests and responses through a small selection layer. More advanced versions also track bursts and outstanding transactions so a bank conflict does not silently break ordering.

## Clocking, Reset, and Timing Assumptions

Callers must understand whether ordering is preserved globally, per bank, or only after an external reorder stage. Reset should clear outstanding mapping state if responses can return later than requests.

## Latency, Throughput, and Resource Considerations

The goal is higher effective bandwidth, but conflict behavior determines whether that benefit appears in real traffic. Cost comes from address mapping logic, routing multiplexers, and any per-bank tracking state.

## Verification Strategy

- Check bank selection and local address mapping across a wide address range.
- Exercise bursts that cross bank boundaries.
- Stress same-bank conflict cases and verify the documented conflict policy.
- Verify ordering guarantees with a reference transaction model.

## Integration Notes and Dependencies

bank_interleaver usually feeds RAM wrappers, scratchpads, frame buffers, or DMA front ends. It should share a stable striping rule with any software-visible memory map or companion reorder logic.

## Edge Cases, Failure Modes, and Design Risks

- Implicit ordering assumptions are the biggest system hazard.
- A bank mapping rule that looks balanced for sequential traffic may be poor for real access patterns.
- Conflict handling must be explicit or throughput estimates will be meaningless.

## Related Modules In This Domain

- burst_adapter
- scratchpad_controller
- dma_engine
- dp_ram_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bank Interleaver module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
