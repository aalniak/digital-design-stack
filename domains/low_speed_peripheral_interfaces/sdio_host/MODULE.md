# Sdio Host

## Overview

sdio_host provides a host-side digital interface for SDIO or SD-style card communication, including command issuance, response handling, and data transfer under a documented feature subset. It is the removable-card serial-host primitive of the low-speed interface layer.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

SDIO host behavior involves command framing, response parsing, transfer timing, and error handling that quickly exceed simple serial-shift logic. sdio_host centralizes those concerns while making supported modes explicit.

## Typical Use Cases

- Read and write data blocks from SD-style media or devices.
- Communicate with SDIO peripherals under software or DMA control.
- Provide a compact host interface for removable or embedded card-style storage.

## Interfaces and Signal-Level Behavior

- Card-facing signals typically include clock, command, and data lines with configurable width.
- Host-facing controls include command issue, argument, transfer setup, and status.
- Status usually reports command complete, transfer complete, busy, CRC error, timeout, and card detection if available.

## Parameters and Configuration Knobs

- BUS_WIDTH_SUPPORT defines supported 1-bit or 4-bit transfers.
- MAX_BLOCK_LEN sets supported block size.
- DMA_HOOK_EN enables a companion data mover path.
- TIMEOUT_CONFIG_MODE controls host-visible timeout tuning.
- MODE_SUBSET documents which speed and command features are intentionally supported.

## Internal Architecture and Dataflow

An SDIO host usually contains a command engine, response parser, data transfer path, and host buffering or FIFO support. The critical contract question is the supported feature subset and whether the host side views transfers as simple commands, block operations, or a richer queue model.

## Clocking, Reset, and Timing Assumptions

The implementation should make card-detect, write-protect, and mode limitations explicit where relevant. Reset should leave the interface idle and clear partial command or transfer state.

## Latency, Throughput, and Resource Considerations

Throughput depends on bus width, clock mode, and whether DMA or buffering reduces software overhead. Compared with more complex storage hosts, this module often prioritizes manageable scope over exhaustive standard coverage.

## Verification Strategy

- Exercise command-response sequences in the supported mode subset.
- Check read and write transfers with CRC and timeout error injection.
- Verify card-busy and transfer-complete behavior.
- Confirm unsupported modes or commands fail in a documented way.

## Integration Notes and Dependencies

sdio_host commonly pairs with DMA, firmware, and boot logic, and it sits near qspi or eMMC interfaces in storage-oriented systems. Its feature scope should be obvious enough that software never assumes more than exists.

## Edge Cases, Failure Modes, and Design Risks

- Supported-mode ambiguity is the largest integration risk.
- Command and data completion semantics must align or buffers may be reused too early.
- Removable-media style status such as card-detect can be mishandled if the board assumptions are not explicit.

## Related Modules In This Domain

- emmc_lite_host
- qspi_flash_interface
- dma_engine
- burst_adapter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Sdio Host module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
