# SPI Master/Slave Controller

## Overview

The SPI master/slave controller provides a configurable serial peripheral interface endpoint that can originate transfers as a bus master or respond to an upstream host as a slave. It bridges software-visible control and status registers to a compact shift-engine datapath and is intended for sensors, converters, flash-adjacent housekeeping devices, and simple board-management links.

## Domain Context

Low-speed peripheral interface modules anchor configuration, service, and housekeeping traffic around the SoC. In this domain, the emphasis is deterministic register access, straightforward pin-level behavior, recoverable protocol error handling, and clean integration into control-plane fabrics rather than raw throughput.

## Problem Solved

Board-level SPI traffic looks simple at the pin level but becomes error-prone when mode selection, chip-select timing, word framing, and back-to-back transfers are left to ad hoc state machines. This module centralizes clock polarity and phase handling, transfer sequencing, and byte packing so the rest of the design sees a stable command/data interface instead of raw serial edges.

## Typical Use Cases

- Driving off-chip configuration peripherals such as ADCs, DACs, clock generators, and mixed-signal front ends.
- Acting as an SPI slave so an external MCU can inspect status or push commands into the FPGA fabric.
- Providing a reusable serial control path for lab bring-up boards where software needs simple register-style access.

## Interfaces and Signal-Level Behavior

- System side typically exposes a CSR or FIFO interface with transfer start, mode selection, data payload, completion, and error flags.
- SPI pins include SCLK, MOSI, MISO, and one or more chip-select outputs or slave-select inputs depending on the configured role.
- Optional ready-valid buffering on the parallel side helps decouple software writes or upstream logic from the serial bit timing.

## Parameters and Configuration Knobs

- Clock divider or bit-rate setting to derive SCLK from the system clock.
- Clock polarity, clock phase, frame width, bit order, and number of chip selects.
- Master-only, slave-only, or dual-role build options plus FIFO depth and timeout behavior.

## Internal Architecture and Dataflow

The core is usually organized around a command register block, a transmit and receive staging path, and a shift engine that emits or samples one bit per SCLK edge according to the selected SPI mode. In master mode, the controller owns chip-select assertion and inter-frame timing. In slave mode, the design must safely capture external SCLK-domain activity and present assembled words back into the internal clock domain with explicit framing and overrun reporting.

## Clocking, Reset, and Timing Assumptions

If slave support is enabled, the external SPI clock is asynchronous to the system fabric clock and needs either bit-level synchronization logic or a dedicated input-clocked capture path. Reset should leave the bus idle with chip selects deasserted and stale receive data invalidated before the first transaction.

## Latency, Throughput, and Resource Considerations

Area and timing are usually dominated by the shift path, clock divider, and optional FIFOs rather than heavy arithmetic. Throughput is bounded by the serial clock, but sustained efficiency depends on how well the parallel side can keep transmit data queued and drain received data without bubbles between frames.

## Verification Strategy

- Exercise all CPOL and CPHA combinations with loopback and protocol-aware scoreboards.
- Check corner cases around partial words, chip-select gaps, underrun, overrun, and role switching if the implementation supports both modes.
- Inject asynchronous slave-clock scenarios and verify receive framing remains correct across clock-domain boundaries.

## Integration Notes and Dependencies

This block commonly sits behind AXI-Lite, APB, or a lightweight local CSR bank and often benefits from DMA only when long sensor bursts are expected. Board-level integration must confirm I/O standards, required chip-select polarity, and whether shared-bus arbitration is handled internally or by a higher-level controller.

## Edge Cases, Failure Modes, and Design Risks

- Mode mismatches across controller and peripheral devices silently corrupt data without obvious protocol faults.
- Slave-mode implementations are vulnerable to metastability or sample-edge mistakes if the external clock path is treated like synchronous logic.
- Software may assume byte-granular framing while the hardware is configured for larger words, leading to swapped or truncated payloads.

## Related Modules In This Domain

- qspi_flash_interface
- i2c_master_slave
- uart_controller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SPI Master/Slave Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
