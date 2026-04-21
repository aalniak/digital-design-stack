# Data Cache

## Overview

Data Cache stores recently used data lines and services processor memory accesses with lower average latency than backing memory. It provides locality-aware acceleration for the processor data path.

## Domain Context

A data cache accelerates load and store traffic between the processor and slower backing memory. In this domain it also defines key platform semantics around write policy, coherency, and how accelerators or DMA-like engines observe shared memory.

## Problem Solved

Raw memory latency can dominate processor performance, but adding a data cache introduces semantic questions about coherency, writeback, and interaction with noncore agents. A dedicated cache block makes those tradeoffs explicit.

## Typical Use Cases

- Reducing average load-store latency for software running from shared memory.
- Providing write buffering and locality benefits in embedded processor subsystems.
- Exploring cache size and policy tradeoffs in accelerator-coupled SoCs.
- Serving as the processor-visible cache layer before external DRAM or SRAM.

## Interfaces and Signal-Level Behavior

- Inputs include core load-store requests, memory-fill and writeback responses, and maintenance or flush controls.
- Outputs provide read data, miss or stall behavior, and writeback traffic to memory.
- Control interfaces configure cache enable, invalidate or flush operations, and optional policy modes.
- Status signals may expose fill_active, writeback_pending, and fault or parity status if supported.

## Parameters and Configuration Knobs

- Cache size, associativity, and line size.
- Write policy such as writeback or writethrough.
- Maintenance-operation support.
- Optional ECC or parity and miss-status handling registers.

## Internal Architecture and Dataflow

The cache typically includes tag and data arrays, dirty-state tracking, refill and eviction control, and maintenance logic. The key contract is coherency: whether noncore agents must use explicit flush and invalidate operations or whether some stronger hardware coherence exists, because software and accelerator integration depend on that answer.

## Clocking, Reset, and Timing Assumptions

The block assumes the backing memory and bus system tolerate the chosen fill and writeback burst patterns. Reset should define whether dirty lines are discarded or impossible by reset construction. If uncached or device-memory regions exist, their address classification rules should be explicit.

## Latency, Throughput, and Resource Considerations

Data-cache effectiveness depends heavily on workload locality and miss penalty. Area and power grow with capacity and associativity. The central tradeoff is between stronger hit rate and the increased complexity of maintenance, eviction, and accelerator interaction.

## Verification Strategy

- Compare cache behavior against a memory-system reference for loads, stores, misses, and evictions.
- Stress writeback, flush, invalidate, and mixed cached or uncached accesses.
- Verify interaction with noncore memory modifiers under the documented coherence model.
- Check error handling and dirty-line policy across reset and fault conditions.

## Integration Notes and Dependencies

Data Cache is tightly coupled to the core wrapper and must align with Accelerator Dispatcher, DMA-like engines, and software cache-maintenance policy. It should be documented as part of the whole platform memory-consistency story, not just as an isolated performance block.

## Edge Cases, Failure Modes, and Design Risks

- Weakly documented coherence with accelerators or DMA is a classic source of SoC integration bugs.
- A cache that drops dirty lines on reset without system-level policy can lose critical state unexpectedly.
- Software and hardware often disagree about maintenance requirements unless address-class and policy rules are explicit.

## Related Modules In This Domain

- instruction_cache
- accelerator_dispatcher
- scratchpad_tcm
- mmu_lite

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Data Cache module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
