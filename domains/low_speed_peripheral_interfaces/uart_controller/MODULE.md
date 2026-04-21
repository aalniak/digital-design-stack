# UART Controller

## Overview

The UART controller implements asynchronous serial transmit and receive for console access, debug traffic, bootstrapping, and simple device-to-device messaging. It wraps baud-rate generation, start and stop bit timing, optional parity handling, and buffering so software or fabric logic can treat the link as a byte stream rather than managing pulse timing directly.

## Domain Context

Low-speed peripheral interface modules anchor configuration, service, and housekeeping traffic around the SoC. In this domain, the emphasis is deterministic register access, straightforward pin-level behavior, recoverable protocol error handling, and clean integration into control-plane fabrics rather than raw throughput.

## Problem Solved

Asynchronous serial lines have no forwarded clock, so robust reception depends on careful oversampling, bit-center timing, framing checks, and error reporting. This module packages those concerns together and prevents each project from rebuilding fragile one-off UART logic for bring-up and diagnostics.

## Typical Use Cases

- Providing a debug console for firmware logs, shell access, or boot messages.
- Linking the FPGA to an MCU, USB bridge, or radio module that only needs modest byte-oriented throughput.
- Offering a simple manufacturing or lab-control interface when richer buses are unnecessary.

## Interfaces and Signal-Level Behavior

- Parallel side commonly exposes transmit write data, receive read data, status flags, interrupt enables, and optional FIFO occupancy counters.
- External pins are a transmit line and receive line, with optional modem-control signals in richer implementations.
- Error outputs usually distinguish framing, parity, break, and receive-overrun conditions so software can react appropriately.

## Parameters and Configuration Knobs

- Baud-rate divisor, oversampling ratio, parity mode, stop-bit count, and data width.
- Transmit and receive FIFO depths plus optional interrupt thresholds.
- Support for auto-baud detection, hardware flow control, or local loopback if those features are required.

## Internal Architecture and Dataflow

A practical implementation combines a baud generator, a transmit shifter, a receive oversampler with start-bit qualification, and shallow FIFOs on both sides. The receive path usually locks onto a detected start edge, samples near each bit center, and checks framing at the stop bit before publishing a byte. The transmit path inserts start, data, optional parity, and stop fields around each queued payload byte.

## Clocking, Reset, and Timing Assumptions

Because the remote transmitter clock is independent, the receiver must tolerate bounded baud mismatch through oversampling and mid-bit sampling margins. Reset should flush both FIFOs and return the line to the idle mark state before any new traffic is accepted.

## Latency, Throughput, and Resource Considerations

UART logic is lightweight in area, but robustness matters more than raw resource efficiency. Sustained throughput is limited by the configured baud rate and can degrade further if software drains receive data too slowly and overrun protection is not sized well.

## Verification Strategy

- Run loopback tests across multiple baud divisors, parity modes, and stop-bit configurations.
- Inject baud mismatch, jitter, breaks, parity errors, and framing errors to verify flag behavior and receiver recovery.
- Confirm FIFO thresholds and interrupts behave correctly during bursty console traffic.

## Integration Notes and Dependencies

UART controllers typically sit on a low-latency CSR bus and are often among the first peripherals used during board bring-up, so pin multiplexing and reset sequencing deserve extra care. If the UART is used for boot loading, its timeout policy and receive buffering need to be documented clearly for firmware teams.

## Edge Cases, Failure Modes, and Design Risks

- Incorrect baud-divisor calculation creates intermittent corruption that may only appear on certain crystals or clock trees.
- Insufficient receive buffering can drop logs or commands during interrupt latency spikes.
- Noise on idle lines can be mistaken for start bits if the receiver lacks enough qualification filtering.

## Related Modules In This Domain

- usb_fs_device_core
- spi_master_slave
- gpio_bank

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the UART Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
