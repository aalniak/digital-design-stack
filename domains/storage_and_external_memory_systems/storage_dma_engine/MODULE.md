# Storage DMA Engine

## Overview

The storage DMA engine moves block or stream payloads between storage-facing controllers and memory without forcing software to copy data word by word. It is the payload mover that lets storage protocols focus on commands while keeping sustained throughput high.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Storage controllers often spend their complexity budget on protocol timing and media semantics, not on moving large payloads efficiently. Without DMA, data paths stall on software servicing or shallow FIFOs. This module provides descriptor-driven data movement so storage reads and writes can stream into memory or out to media at practical rates.

## Typical Use Cases

- Moving SD, eMMC, SATA, or flash payloads between controllers and DDR.
- Feeding or draining staging buffers for storage queues and file-system software.
- Decoupling command issuance from bulk payload transport in data-logging systems.

## Interfaces and Signal-Level Behavior

- Descriptor side accepts source or destination addresses, length, direction, and completion metadata.
- Memory side connects to DDR or local memory buses for burst reads and writes.
- Storage side presents streaming or block-oriented payload interfaces toward host controllers or media engines.

## Parameters and Configuration Knobs

- Maximum burst size, descriptor depth, alignment rules, scatter-gather support, and outstanding transaction count.
- Stream width, end-of-transfer signaling, and completion reporting detail.
- Optional checksum, ECC handoff, or cache-coherency support depending on system architecture.

## Internal Architecture and Dataflow

A storage DMA engine generally includes descriptor parsing, burst planning, read or write data movers, boundary handling for unaligned transfers, and completion reporting. It often supports both storage-to-memory and memory-to-storage directions, with buffering that smooths over the mismatch between media-side cadence and memory-side burst efficiency.

## Clocking, Reset, and Timing Assumptions

The engine assumes descriptors describe valid address ranges and that upper layers manage any filesystem or block-mapping semantics. Reset and error paths should leave descriptor status unambiguous so software can determine whether a payload moved fully, partially, or not at all.

## Latency, Throughput, and Resource Considerations

Throughput depends on burst size, descriptor granularity, and the behavior of the memory subsystem more than on the storage control path itself. Area is moderate and dominated by buffers, address generators, and outstanding-request tracking.

## Verification Strategy

- Verify both directions across aligned and unaligned transfers, short blocks, and long streams.
- Check backpressure behavior between storage and memory sides so data is neither duplicated nor dropped.
- Exercise descriptor errors, partial completions, and reset during active transfers.

## Integration Notes and Dependencies

This engine typically lives under storage host controllers and above DDR or scratchpad memories. Integrators should define whether software observes per-transfer completion, per-descriptor completion, or queue-level progress and how cache maintenance is handled if processors share the target memory.

## Edge Cases, Failure Modes, and Design Risks

- Descriptor and payload completion semantics can diverge if not specified carefully.
- Unaligned edge cases may work on one bus width and fail on another if byte-enable handling is incomplete.
- If memory arbitration starves DMA, storage controllers may timeout even though the media path is healthy.

## Related Modules In This Domain

- pcie_dma_engine
- ddr_scheduler_frontend
- emmc_host_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Storage DMA Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
