# Scratchpad Controller

## Overview

scratchpad_controller manages a software- or hardware-addressable local memory region with simple access semantics and explicit ownership. It is the predictable, non-coherent local-memory alternative to a cache controller.

## Domain Context

In the Buffering, Memory, and Data Movement domain, modules are judged by how clearly they define storage ownership, latency, burst semantics, backpressure, coherency boundaries, and error behavior. These blocks frequently sit between fast producers, slower memories, and shared interconnect.

## Problem Solved

Many accelerators and tightly controlled dataflows prefer local deterministic storage over cache behavior. scratchpad_controller provides a reusable front end for that style of memory without hidden allocation or replacement policy.

## Typical Use Cases

- Expose local memory to a processor or accelerator with deterministic address mapping.
- Stage working sets under software control.
- Provide a bounded-latency local store for real-time kernels.

## Interfaces and Signal-Level Behavior

- Client-side inputs usually include address, read or write control, byte enables, and data.
- Memory-side interfaces may be a local RAM wrapper or banked storage implementation.
- Status may expose access errors, busy state during maintenance operations, or bank conflicts.

## Parameters and Configuration Knobs

- ADDRESS_WIDTH and DATA_WIDTH size the visible space.
- BANKING_EN enables banked scratchpad layouts.
- BYTE_ENABLE_EN supports partial writes.
- PROTECTION_EN enables bounds or permission checks.
- DMA_PORT_EN adds a side port for load and store from a DMA engine.

## Internal Architecture and Dataflow

The controller typically provides straightforward address decode, optional bank selection, access arbitration, and possibly a side path for DMA or maintenance traffic. Its defining trait is explicit local ownership rather than transparent caching.

## Clocking, Reset, and Timing Assumptions

Clients must know the memory map and whether any other agent can access the same storage concurrently. Reset should define whether contents are preserved, invalid, or explicitly initialized.

## Latency, Throughput, and Resource Considerations

Scratchpads are valuable because access latency is predictable. Throughput depends on banking, arbitration, and the attached RAM style. Hardware cost is moderate and mostly in decode and arbitration rather than policy machinery.

## Verification Strategy

- Check address decode and access latency.
- Exercise partial writes, side-port traffic, and bank conflicts if supported.
- Verify bounds or permission faults.
- Stress concurrent access paths and confirm documented arbitration policy.

## Integration Notes and Dependencies

scratchpad_controller often pairs with bank_interleaver, RAM wrappers, DMA, and compute engines that want deterministic local memory. It should define clearly whether it is software-managed, hardware-managed, or shared.

## Edge Cases, Failure Modes, and Design Risks

- Clients may accidentally assume cache-like behavior if the deterministic local-memory contract is not emphasized.
- Concurrent access policy must be explicit or hidden interference will appear.
- Initialization and reset semantics matter because software often expects scratchpad contents to be under explicit control.

## Related Modules In This Domain

- bank_interleaver
- sp_ram_wrapper
- dp_ram_wrapper
- dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Scratchpad Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
