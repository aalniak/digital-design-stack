# SD Host Controller

## Overview

The SD host controller manages command, response, and block data transfers for Secure Digital cards and related removable media. It provides a structured host-side interface for card discovery, configuration, and data movement without exposing raw pin timing to software.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Removable SD media requires initialization sequencing, voltage or mode negotiation, response decoding, data CRC checks, and careful timeout handling. A dedicated host block is needed so system software can issue card commands and move blocks through a stable register or DMA interface.

## Typical Use Cases

- Adding removable storage or data export capability to an FPGA-based instrument.
- Booting or loading assets from SD cards in embedded systems.
- Capturing moderate-rate data streams to commodity removable media.

## Interfaces and Signal-Level Behavior

- Software side usually exposes command issue, response capture, clock control, interrupt status, and block-transfer setup.
- Card side drives SD clock, command, and data pins with width switching and response sampling control.
- Data side connects to FIFOs or DMA for block payload movement between the card and memory.

## Parameters and Configuration Knobs

- Supported bus widths, clock divider range, block size limits, timeout counters, and response-type support.
- DMA coupling style, CRC and error status exposure, and whether advanced UHS timing is included.
- Card-detect and write-protect input handling options.

## Internal Architecture and Dataflow

The controller contains a command sequencer, response parser, clock and width management, data transfer state machines, and optional DMA handshakes for multi-block operations. It handles card initialization and ordinary block reads or writes while publishing enough status for software to recover from card removal, CRC errors, or timeouts.

## Clocking, Reset, and Timing Assumptions

Different SD card generations and speed modes impose different timing and voltage expectations, so the implemented subset should be documented precisely. Reset must leave the bus and software-visible state in a way that tolerates card insertion or removal at any time.

## Latency, Throughput, and Resource Considerations

Throughput depends on supported bus width, clock mode, and how efficiently the data path avoids CPU copy overhead. Resource usage is moderate and shaped by protocol state and data buffering.

## Verification Strategy

- Verify card initialization, command or response handling, and block transfers across supported modes.
- Inject CRC errors, timeouts, card removal, and late software servicing of data buffers.
- Check multi-block sequencing and stop-command behavior when transfers are aborted.

## Integration Notes and Dependencies

This controller typically pairs with software drivers and either local FIFOs or a DMA engine. Integration should define hot-plug expectations, supported card classes, and whether the design exposes standard host-controller semantics or a simplified custom register model.

## Edge Cases, Failure Modes, and Design Risks

- Card-removal edge cases can strand the controller in busy state if not handled explicitly.
- Sampling margins that work at low speed may fail at higher bus rates without tuning support.
- Software may assume broad SD compatibility when the implemented subset is narrower.

## Related Modules In This Domain

- emmc_host_controller
- storage_dma_engine
- spi_flash_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SD Host Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
