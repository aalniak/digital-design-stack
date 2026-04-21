# SPI Flash Controller

## Overview

The SPI flash controller accesses serial NOR flash devices used for boot images, configuration data, and moderate-bandwidth non-volatile storage. It wraps command sequencing, address phases, mode switching, and data transfer behavior behind a reusable host-side interface.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Serial flash devices appear simple but differ in command set, read mode, address width, and erase or program sequencing. Rebuilding that logic repeatedly leads to brittle boot paths. This module standardizes flash command execution so software and adjacent logic can rely on a consistent storage contract.

## Typical Use Cases

- Loading FPGA or system boot assets from serial NOR flash.
- Storing calibration tables, firmware bundles, or configuration blobs in non-volatile memory.
- Providing a simple host-managed persistent store when bandwidth needs are modest.

## Interfaces and Signal-Level Behavior

- Control side issues read, page-program, sector-erase, and status commands with address and length information.
- Pin or SPI side drives serial flash signals either directly or through a lower SPI engine.
- Data side connects to local buffers, memory-mapped read windows, or DMA for payload movement.

## Parameters and Configuration Knobs

- Single, dual, or quad I/O support, address width, clock divider range, and command profile selection.
- Page size, erase-sector size, deep-power-down support, and memory-mapped read options.
- FIFO depth and whether execute-in-place style reads are supported or only explicit transactions.

## Internal Architecture and Dataflow

The controller sequences command opcodes, address cycles, dummy cycles, and data phases according to the selected flash profile. Some implementations provide a command mode for management operations and a separate direct-read or mapped-read mode for boot or lookup traffic. Program and erase operations require careful status polling and write-enable discipline, which is where most controller complexity lives.

## Clocking, Reset, and Timing Assumptions

The block should make clear which flash families or command conventions it targets. Reset and power-up handling are important because many boot scenarios depend on the first read after reset behaving deterministically even before software has reconfigured the controller.

## Latency, Throughput, and Resource Considerations

Serial flash is slow compared with DDR or PCIe storage, but quad modes and burst reads can still be useful for boot and configuration workloads. Area is low to moderate and largely control dominated.

## Verification Strategy

- Verify command sequencing for reads, programs, erases, and status polling.
- Check address-width changes, dummy-cycle handling, and mode transitions such as quad-enable paths.
- Exercise reset during long program or erase operations and confirm the recovery policy is documented.

## Integration Notes and Dependencies

This controller often underpins boot paths, so software and hardware both depend on it being conservative and well documented. Integration should define whether access is memory mapped, command driven, or both, and who owns flash-partition layout.

## Edge Cases, Failure Modes, and Design Risks

- Mode-bit or dummy-cycle mismatches can return plausible but wrong data during high-speed reads.
- Program or erase recovery after reset is often overlooked and can leave flash in an unexpected state.
- If controller assumptions are too vendor-specific, swapping flash parts becomes painful.

## Related Modules In This Domain

- qspi_flash_interface
- emmc_host_controller
- sd_host_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SPI Flash Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
