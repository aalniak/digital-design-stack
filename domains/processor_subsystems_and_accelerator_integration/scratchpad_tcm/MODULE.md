# Scratchpad/TCM

## Overview

Scratchpad/TCM provides directly addressed low-latency memory tightly integrated with the processor or accelerator subsystem. It offers deterministic storage and bandwidth under explicit software or hardware management.

## Domain Context

Scratchpad memories and tightly coupled memories provide deterministic low-latency storage without the unpredictability of cache replacement. In this domain they are the architectural tool for real-time code, data, or accelerator-shared buffers that need explicit software placement.

## Problem Solved

Caches improve average performance but can make latency unpredictable. A dedicated TCM or scratchpad block gives software and hardware a deterministic memory region for critical routines, stacks, or shared working sets.

## Typical Use Cases

- Hosting interrupt handlers or real-time control loops in deterministic memory.
- Providing explicitly managed working memory for accelerator-coupled software.
- Reducing bus contention for hot code or data regions.
- Supporting mixed cache-plus-TCM architectures in embedded SoCs.

## Interfaces and Signal-Level Behavior

- Inputs include core or accelerator memory accesses, optional initialization or load controls, and reset context.
- Outputs provide low-latency read and write responses with deterministic timing under the documented access model.
- Control interfaces configure region size, protection, and optional memory initialization.
- Status signals may expose region_enable, access_fault, and parity or ECC status if supported.

## Parameters and Configuration Knobs

- Memory size and port count.
- Instruction-side, data-side, or dual-use mapping.
- Protection and privilege options.
- Optional ECC or parity support.

## Internal Architecture and Dataflow

The block is typically an SRAM or closely coupled memory wrapper with direct address decoding and minimal arbitration. The critical contract is which masters may access it and under what timing guarantees, because software often relies on TCM determinism for hard real-time behavior.

## Clocking, Reset, and Timing Assumptions

The module assumes the address map reserves the TCM region and software or firmware explicitly places code or data there as needed. Reset behavior should define whether contents are initialized, retained, or undefined. If accelerators also access the region, arbitration and visibility rules must be explicit.

## Latency, Throughput, and Resource Considerations

TCM offers stable latency and high local bandwidth, often at the cost of software-managed placement and limited size. The main tradeoff is determinism versus capacity and management burden compared with caches.

## Verification Strategy

- Verify deterministic access timing and basic memory correctness.
- Check privilege and protection behavior across expected masters.
- Stress simultaneous access if dual-port or shared modes are supported.
- Validate initialization and retention semantics across the intended reset and boot flows.

## Integration Notes and Dependencies

Scratchpad/TCM connects directly to the processor wrapper and sometimes to accelerator datapaths or dispatch logic. It should align with linker scripts, boot software, and any DMA or accelerator access policy so the region remains a predictable resource.

## Edge Cases, Failure Modes, and Design Risks

- Software placement errors can negate the benefits of TCM while remaining hard to diagnose from hardware alone.
- Shared accelerator access can undermine determinism if arbitration is not clear.
- Retention or initialization ambiguity across reset can create subtle startup bugs in real-time code.

## Related Modules In This Domain

- riscv_core_wrapper
- instruction_cache
- data_cache
- accelerator_dispatcher

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Scratchpad/TCM module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
