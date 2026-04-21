# USB Full-Speed Device Core

## Overview

The USB full-speed device core terminates a USB 2.0 full-speed device link and presents packetized endpoint traffic to the fabric. It is aimed at control interfaces, virtual COM ports, firmware update channels, and low-bandwidth streaming applications where standardized PC connectivity matters more than maximum throughput.

## Domain Context

Low-speed peripheral interface modules anchor configuration, service, and housekeeping traffic around the SoC. In this domain, the emphasis is deterministic register access, straightforward pin-level behavior, recoverable protocol error handling, and clean integration into control-plane fabrics rather than raw throughput.

## Problem Solved

USB device behavior is governed by strict packet framing, CRC rules, endpoint semantics, enumeration state, and timing expectations set by a host-driven bus. Implementing those rules from scratch is expensive and easy to get subtly wrong. This module consolidates token parsing, endpoint dispatch, handshakes, and bus reset handling into a reusable device-side core.

## Typical Use Cases

- Enumerating the FPGA as a control or debug device on a host PC without requiring external bridge chips.
- Exposing firmware upgrade, telemetry, or simple bulk data channels through standardized USB endpoints.
- Building lab instruments that need plug-and-play host connectivity for configuration and data retrieval.

## Interfaces and Signal-Level Behavior

- Upstream fabric side typically exposes endpoint FIFOs or packet streams for control, bulk, interrupt, or limited isochronous traffic.
- PHY-facing side may connect to a UTMI-like wrapper, a serial interface engine, or board-level D+ and D- pins through an external transceiver front end.
- Status and control registers report bus reset, suspend, resume, address state, endpoint readiness, and protocol-error conditions.

## Parameters and Configuration Knobs

- Number and type of endpoints, maximum packet size per endpoint, and whether endpoint zero control transfer support is fixed or configurable.
- Choice of PHY-side wrapper, packet-buffer depth, and optional DMA coupling for higher sustained traffic.
- Feature limits such as only full-speed mode, supported descriptor storage strategy, and endpoint buffering policy.

## Internal Architecture and Dataflow

The core normally includes a serial interface engine or PHY wrapper, token and packet decoders, CRC generation and checking, endpoint state machines, and a control-transfer engine that handles setup packets and standard requests at endpoint zero. Received host packets are checked, routed to the correct endpoint buffer, and acknowledged only when the endpoint can safely accept them. Transmit paths arbitrate among ready endpoints and return well-formed data or handshake packets during host polling.

## Clocking, Reset, and Timing Assumptions

USB traffic is host scheduled, so the device core must be able to react within protocol timing budgets once a token arrives. Reset handling should explicitly cover power-on reset, USB bus reset, suspend, and resume transitions so endpoint state is not left ambiguous after host re-enumeration.

## Latency, Throughput, and Resource Considerations

Full-speed USB tops out far below internal fabric bandwidth, so the main performance concerns are packet turnaround latency, endpoint buffering, and avoiding stalls caused by software not servicing descriptors or FIFOs quickly enough. Area increases with endpoint count, packet RAM, and control-transfer sophistication.

## Verification Strategy

- Exercise enumeration, address assignment, standard control requests, endpoint stalls, and recovery from bus reset.
- Validate CRC handling, token decoding, data toggle management, and handshake sequencing under normal and malformed host traffic.
- Run endpoint stress tests where software or fabric logic intentionally services buffers late to confirm NAK, stall, and retry behavior.

## Integration Notes and Dependencies

This core often depends on descriptor ROMs, endpoint FIFOs, and sometimes a thin software layer that responds to control requests not handled entirely in hardware. Integration must also confirm whether the design includes the required analog front end, pull-up control, and clock accuracy needed by full-speed USB signaling.

## Edge Cases, Failure Modes, and Design Risks

- Incomplete control-transfer handling can allow enumeration to appear correct at first while later standard requests fail.
- Endpoint buffering mistakes often surface only under host retry or back-to-back packet conditions.
- Clock tolerance, reset timing, or PHY wrapper mismatches can create protocol failures that look like random host disconnects.

## Related Modules In This Domain

- uart_controller
- spi_master_slave
- sdio_host

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the USB Full-Speed Device Core module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
