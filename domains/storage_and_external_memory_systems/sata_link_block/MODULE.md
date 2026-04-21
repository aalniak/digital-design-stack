# SATA Link Block

## Overview

The SATA link block implements the framing, sequencing, and flow-control layer that sits between a SATA transport or command engine and the serial PHY. It turns storage transactions into link-level FIS exchanges and ordered primitives rather than raw bit streams.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

SATA is more than serializing bytes. The link layer must handle frame boundaries, primitives, CRC protection, synchronization, and retry or error behavior. This module encapsulates those responsibilities so higher storage logic can work with FIS-level semantics instead of line-management details.

## Typical Use Cases

- Connecting an AHCI-like frontend to a SATA device through a structured link layer.
- Building capture or appliance systems that use SATA drives directly from FPGA logic.
- Experimenting with transport-level storage designs above a reusable SATA framing core.

## Interfaces and Signal-Level Behavior

- Upper side exchanges frame information structures, data payloads, and command or status metadata with transport logic.
- Lower side connects to a PHY or PCS adaptation layer that handles serialization and electrical link bring-up.
- Status outputs report link state, CRC failures, primitive errors, and recovery events.

## Parameters and Configuration Knobs

- Supported SATA generation, CRC profile, retry policy, buffering depth, and primitive handling set.
- Transmit and receive queue depth, frame-size limits, and optional low-power behavior.
- Whether the block includes some transport conveniences or remains strictly link-layer.

## Internal Architecture and Dataflow

The block typically formats outbound FIS payloads into link frames, inserts CRC protection, arbitrates primitives for synchronization and flow control, and decodes inbound frames back into structured information for upper layers. Link-state tracking is important because command engines need a clean notion of when the channel is truly ready for new traffic versus recovering from an error.

## Clocking, Reset, and Timing Assumptions

The serial PHY or PCS below this block must already satisfy electrical and basic coding requirements. Reset sequencing should coordinate carefully with link startup so stale inbound fragments are not mistaken for the beginning of a new frame after reinitialization.

## Latency, Throughput, and Resource Considerations

SATA performance is bounded by negotiated link rate and media latency, but the link block should still sustain back-to-back frame movement without inserting avoidable bubbles. Resource use is moderate and driven by buffers, CRC logic, and link-state handling.

## Verification Strategy

- Verify FIS framing, CRC handling, primitive sequencing, and normal link bring-up behavior.
- Inject malformed frames, CRC errors, and link interruptions to confirm recovery paths.
- Check interaction with upper transport logic during stalls or partial frame aborts.

## Integration Notes and Dependencies

This block sits between higher storage command engines and lower serial infrastructure. Integrators should define which layer owns timeouts, retries, and power-state transitions, since those responsibilities can blur across SATA layers.

## Edge Cases, Failure Modes, and Design Risks

- If primitive handling is incomplete, links may appear up but fail under error recovery or corner-case traffic.
- Boundary confusion between link and transport responsibilities can duplicate or omit retry behavior.
- CRC or frame abort mistakes can create rare corruption that only emerges with long transfers.

## Related Modules In This Domain

- ahci_lite_frontend
- crc_engine
- pcs_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SATA Link Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
