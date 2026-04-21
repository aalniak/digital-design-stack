# Aurora-Style Link

## Overview

The Aurora-style link module provides a lightweight framed transport over serial transceivers for board-to-board or chip-to-chip streaming. It is intended for cases where designers want lane bring-up, framing, and error detection without the full overhead of Ethernet or PCIe.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

High-speed serial lanes need alignment, framing, and error monitoring before application data can move reliably. Building custom point-to-point links repeatedly wastes effort and often misses subtle startup or recovery details. This module offers a reusable transport shell that standardizes link training, packet or word framing, and flow-control signaling for private interconnects.

## Typical Use Cases

- Streaming sensor or accelerator data between FPGAs on the same board or across a backplane.
- Connecting a custom front-end acquisition card to a compute card with lower overhead than full networking stacks.
- Creating lab infrastructure links where both endpoints are under the same design control.

## Interfaces and Signal-Level Behavior

- Fabric side usually presents an AXI-Stream-like source and sink with packet markers or framing metadata.
- Transceiver side connects to serialized lane data plus reset, polarity, and lane-status controls from the PHY wrapper.
- Status outputs report lane up, channel up, alignment health, soft errors, hard errors, and optional credit state.

## Parameters and Configuration Knobs

- Lane count, lane bonding support, data-path width, optional CRC width, and elastic-buffer depth.
- Flow-control mode, startup timeout values, and recovery thresholds.
- Support for packet boundaries, idle insertion, and optional user-side metadata propagation.

## Internal Architecture and Dataflow

A typical implementation wraps transceiver-facing encode and decode helpers, lane initialization logic, comma or framing symbol detection, optional CRC generation and checking, and elastic buffering that converts line-rate cadence into the internal clocked stream. Multi-lane variants add deskew and channel-bond logic so lane-to-lane skew does not corrupt packet assembly.

## Clocking, Reset, and Timing Assumptions

This module assumes the transceiver wrapper supplies recovered clocks or parallelized data in a stable format and that board-level signal integrity is good enough for the configured line rate. Reset and reinitialization must be coordinated carefully because link training state is not equivalent to simple synchronous reset.

## Latency, Throughput, and Resource Considerations

Throughput scales with lane count and encoding overhead. Latency is usually modest but not free, since training, elastic buffering, CRC checks, and deskew stages add fixed cycles even after the link is up. Resource cost is moderate and grows with bonding and monitoring features.

## Verification Strategy

- Verify cold bring-up, warm reset, loss-of-lock recovery, and lane deskew behavior.
- Inject symbol errors and dropped idles to confirm soft and hard error handling matches the documented recovery policy.
- Stress backpressure or credit behavior so the user stream never overruns internal buffering.

## Integration Notes and Dependencies

The module typically sits on top of device-specific SERDES wrappers and below packet movers, DMA engines, or custom streaming fabrics. Integration work should define link ownership, startup sequencing, and whether higher layers rely on this block alone for integrity or add their own packet checks.

## Edge Cases, Failure Modes, and Design Risks

- Ignoring lane deskew or startup edge cases can yield a link that works in simulation but fails on real boards.
- If the application assumes lossless delivery but the link only reports errors without replay, silent data loss can propagate upward.
- Recovered-clock domain handling can become fragile if line-side logic is mixed loosely with system-clock logic.

## Related Modules In This Domain

- pcs_wrapper
- elastic_buffer
- crc_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Aurora-Style Link module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
