# Packet FIFO

## Overview

packet_fifo buffers framed traffic while preserving start, end, and packet-level sideband semantics. It is the packet-aware elasticity primitive for the library.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

A plain FIFO can preserve beat order but still mishandle packet meaning if framing sidebands are not stored and replayed correctly. packet_fifo solves that gap.

## Typical Use Cases

- Buffer packets between transport and payload logic.
- Absorb burstiness while preserving packet boundaries.
- Decouple parsers, DMA engines, and packet emitters.

## Interfaces and Signal-Level Behavior

- Inputs and outputs usually use valid, ready, data, and packet sidebands.
- Status can include full, empty, almost full, beat occupancy, and optional packet occupancy.
- Error signaling may indicate overflow or dropped-transaction policy.

## Parameters and Configuration Knobs

- DATA_WIDTH and DEPTH size storage.
- PACKET_METADATA_MODE defines how sidebands are stored.
- DROP_POLICY defines behavior on overflow or bad packets.
- PACKET_COUNT_EN enables packet-level occupancy tracking.
- OUTPUT_REG chooses output timing style.

## Internal Architecture and Dataflow

The module is usually a stream FIFO with widened storage or auxiliary bookkeeping for boundary bits and packet status. Whole-packet behavior under overflow is the key architectural question.

## Clocking, Reset, and Timing Assumptions

Reset must return the FIFO to an empty state with no partial packet retained. If packet drop is supported, the module must define whether it can drop only whole packets or may truncate.

## Latency, Throughput, and Resource Considerations

Steady-state throughput should match stream_fifo. Resource cost is slightly higher because packet metadata must move with payload or be reconstructed safely.

## Verification Strategy

- Stress backpressure with single-beat, long, and malformed packets.
- Verify packet boundaries survive pointer wrap and simultaneous enqueue or dequeue.
- Check overflow policy for whole-packet versus partial-packet handling.
- Scoreboard both beat order and packet structure.

## Integration Notes and Dependencies

packet_fifo naturally pairs with packetizer, depacketizer, and routed packet streams. It benefits strongly from one consistent sideband convention.

## Edge Cases, Failure Modes, and Design Risks

- Dropping packet sidebands is equivalent to corrupting data.
- Beat occupancy alone may not tell software how many complete packets are buffered.
- Overflow policy must be explicit or packet-level correctness is impossible to reason about.

## Related Modules In This Domain

- packetizer
- depacketizer
- stream_fifo
- stream_mux

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Packet FIFO module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
