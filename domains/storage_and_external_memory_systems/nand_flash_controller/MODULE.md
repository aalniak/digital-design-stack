# NAND Flash Controller

## Overview

The NAND flash controller issues low-level commands, addresses, and data transfers to raw NAND devices while coordinating page reads, page programs, erase cycles, and status polling. It exposes the raw flash geometry and timing model that managed devices hide.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Raw NAND devices provide cost-effective storage but require careful sequencing of command cycles, address phases, busy polling, spare-area handling, and ECC cooperation. A reusable controller is needed so higher layers can request logical page operations without embedding bus-timing details everywhere.

## Typical Use Cases

- Building raw flash storage subsystems with custom translation layers or boot formats.
- Capturing large datasets into inexpensive NAND while retaining control over layout and reliability strategy.
- Researching flash-management policies on platforms where managed eMMC devices are too opaque.

## Interfaces and Signal-Level Behavior

- Backend bus side drives CLE, ALE, WE, RE, CE, data bus, ready or busy pins, and any interface-specific strobes.
- Control side accepts page-read, page-program, erase, and status operations with logical or physical address information.
- Data side exchanges main-area and spare-area payloads with ECC, DMA, or software-visible buffers.

## Parameters and Configuration Knobs

- Bus width, page size, block size, address-cycle count, timing profile, and plane or die count.
- Support for ONFI-style discovery, cache mode, multi-plane operations, and spare-area access policy.
- Timeout thresholds and whether ECC integration is mandatory or optional.

## Internal Architecture and Dataflow

The controller is usually built around a micro-sequencer or state machine that emits the required command and address cycles, waits for ready or busy completion, and coordinates the data phase for reads and programs. Since erase and program latencies are long relative to the system clock, the block also needs clear status tracking so higher layers can overlap work or poll completion safely.

## Clocking, Reset, and Timing Assumptions

Physical geometry, bad-block marker locations, and timing parameters vary by device, so either run-time discovery or a carefully documented build configuration is required. Reset must leave the NAND bus in an idle state and discard any half-finished operation bookkeeping that cannot be resumed safely.

## Latency, Throughput, and Resource Considerations

Throughput depends on page size, interface width, cache operation support, and how effectively DMA or ECC stages overlap with command latency. Resource usage is moderate and mostly control-path oriented.

## Verification Strategy

- Verify page read, page program, erase, and status sequences against the target device timing model.
- Check spare-area handling, address sequencing, and interaction with ECC and bad-block management.
- Inject ready or busy delays, timeouts, and command failures to confirm robust recovery behavior.

## Integration Notes and Dependencies

This controller rarely stands alone. It depends on ECC, bad-block tracking, and some logical mapping layer that determines where data lives physically. Integration should define which layer owns translation, wear leveling, and power-fail recovery metadata.

## Edge Cases, Failure Modes, and Design Risks

- A controller that assumes one device geometry too rigidly will fail when a new NAND part is introduced.
- Spare-area misuse can collide ECC, bad-block markers, and translation metadata.
- If program or erase failures are not surfaced precisely, higher layers may continue trusting damaged blocks.

## Related Modules In This Domain

- flash_ecc_block
- bad_block_manager
- storage_dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the NAND Flash Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
