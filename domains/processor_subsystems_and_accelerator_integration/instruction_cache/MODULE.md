# Instruction Cache

## Overview

Instruction Cache stores recently fetched instruction lines and serves future fetches at lower latency than backing memory. It provides temporal locality acceleration for the processor instruction stream.

## Domain Context

An instruction cache hides fetch latency between the processor core and backing memory. In this domain it shapes code-fetch performance, coherency assumptions, and how immutable boot regions or self-modifying code interact with the processor subsystem.

## Problem Solved

Processor performance can collapse if every fetch waits on slower system memory. A dedicated instruction cache makes line size, fill policy, and invalidation semantics explicit so software and hardware teams know what fetch behavior to expect.

## Typical Use Cases

- Accelerating execution from external memory or shared fabric.
- Reducing average instruction fetch latency in embedded and application-class systems.
- Providing a configurable hierarchy element between core and memory fabric.
- Supporting platform studies of code locality and cache sizing.

## Interfaces and Signal-Level Behavior

- Inputs include core fetch requests, memory-fill responses, and invalidation or maintenance controls.
- Outputs provide instructions, hit or miss handling, and stall or ready behavior to the core.
- Control interfaces configure cache enable, invalidation, and optional maintenance operations.
- Status signals may expose fill_active, hit_count or performance counters, and parity or ECC faults if supported.

## Parameters and Configuration Knobs

- Cache size, associativity, and line length.
- Fetch port width and fill interface width.
- Replacement policy and lockable-line support if present.
- Optional parity or ECC protection.

## Internal Architecture and Dataflow

The cache usually contains tag and data arrays, replacement metadata, fill-state machines, and invalidate logic. The key contract is how it behaves with respect to instruction-side coherence, especially when boot code, debug agents, or DMA-like agents can modify executable memory.

## Clocking, Reset, and Timing Assumptions

The block assumes backing memory and fetch addresses follow the documented alignment and line-fill rules. Reset may invalidate the entire cache or leave it disabled until configured. If software must explicitly perform instruction-cache invalidation after code modification, that requirement should be stated clearly.

## Latency, Throughput, and Resource Considerations

Instruction cache performance depends on size, associativity, miss penalty, and code locality. Area and power grow with capacity and line width. The important tradeoff is between higher hit rate and the complexity or latency of larger, more associative structures.

## Verification Strategy

- Compare fetch behavior against a cache-coherent or software reference over representative instruction traces.
- Stress misses, refill, invalidation, and branch-heavy access patterns.
- Verify error reporting if parity or ECC is supported.
- Check interactions with debug or code-modification scenarios that require maintenance operations.

## Integration Notes and Dependencies

Instruction Cache sits between the RISC-V Core Wrapper and backing memory or Boot ROM alias paths. It should align with software memory maintenance policy and with any secure-boot assumptions around executable region mutability.

## Edge Cases, Failure Modes, and Design Risks

- Underdocumented instruction coherence behavior is a common source of boot and debug confusion.
- A cache that is functionally correct but too small or too slow to refill can underdeliver real-world core performance.
- Maintenance operation semantics matter greatly if code can be updated after boot.

## Related Modules In This Domain

- data_cache
- boot_rom
- scratchpad_tcm
- debug_module

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Instruction Cache module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
