# PCIe DMA Engine

## Overview

The PCIe DMA engine moves data efficiently between host memory and on-chip buffers using PCI Express transactions rather than software-driven register copies. It is the workhorse for high-bandwidth accelerator input, capture upload, and low-latency host-device streaming.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

PCIe links expose high potential bandwidth, but using that bandwidth requires correct generation of memory read and memory write TLPs, descriptor tracking, completion handling, host addressing, and error recovery. This module packages those mechanics so application logic can request data movement through descriptors and status queues rather than touching raw TLP details.

## Typical Use Cases

- Streaming captured sensor data from device memory into host buffers.
- Fetching work descriptors or tensors from host memory into accelerator-local RAM.
- Providing a generic high-throughput data mover behind a PCIe endpoint wrapper.

## Interfaces and Signal-Level Behavior

- Descriptor side typically accepts source and destination addresses, transfer length, attributes, and completion reporting information.
- PCIe side exchanges request and completion packets with the endpoint transport layer or hard IP wrapper.
- Local memory side connects to AXI, SRAM, or streaming buffers that source or sink payload data.

## Parameters and Configuration Knobs

- Maximum payload size, maximum read request size, outstanding tag count, and descriptor queue depth.
- Support for scatter-gather, interrupt generation, completion coalescing, and address width.
- Timeout behavior, error reporting detail, and ordering rules for reads versus writes.

## Internal Architecture and Dataflow

The engine normally separates descriptor fetch and scheduling, request generation, completion reassembly, write data packing, and completion status handling into cooperating subblocks. Read paths issue host-memory requests, track tags, and reassemble returned completions into ordered local data streams. Write paths packetize local payload into outbound memory writes while honoring payload-size and alignment rules. High-throughput designs add deep outstanding queues and reorder buffers so the link stays busy.

## Clocking, Reset, and Timing Assumptions

This block assumes the endpoint layer already handles PCIe link training and transport framing, leaving the DMA engine responsible for transaction-level behavior. Reset and error recovery must clear or explicitly retire in-flight descriptors so software can reason about which transfers completed and which must be retried.

## Latency, Throughput, and Resource Considerations

Throughput depends on descriptor efficiency, outstanding request depth, host memory latency, and how well payload sizes match negotiated PCIe limits. Resource usage is shaped by tag tracking, buffering, and address translation features rather than arithmetic complexity.

## Verification Strategy

- Exercise read and write descriptors across aligned, unaligned, short, and long transfer sizes.
- Verify completion reordering, tag reuse, timeout handling, and descriptor status reporting under stress.
- Inject malformed or error completions and confirm software-visible failure semantics are deterministic.

## Integration Notes and Dependencies

The DMA engine usually depends on a PCIe endpoint wrapper, descriptor queues, and a local memory subsystem that can sustain the requested throughput. Integrators should define the ownership of address translation, IOMMU interaction if any, and the interrupt or polling contract used by software.

## Edge Cases, Failure Modes, and Design Risks

- Incorrect tag bookkeeping can corrupt data only under heavy outstanding load, making bugs sporadic.
- Unclear error completion semantics leave software unsure whether a transfer partially succeeded.
- If host cache coherency assumptions are wrong, perfectly transmitted DMA data may still look stale to software.

## Related Modules In This Domain

- pcie_endpoint_wrapper
- reorder_buffer
- storage_dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PCIe DMA Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
