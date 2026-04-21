# Depacketizer

## Overview

depacketizer removes transport framing and presents payload plus normalized metadata to downstream logic. It keeps packet syntax at the boundary so payload-processing blocks can stay generic.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

If every consumer has to understand packet headers, byte counts, and boundary quirks, reuse drops quickly. depacketizer centralizes unpacking, header extraction, and malformed-packet policy.

## Typical Use Cases

- Strip protocol headers before a DSP or image pipeline.
- Convert a stored packet record into payload beats plus sidebands.
- Expose packet length, type, and error information in one normalized place.

## Interfaces and Signal-Level Behavior

- Ingress usually accepts valid, ready, data, and packet markers or descriptor fields.
- Egress emits payload data plus first, last, type, length, or error metadata.
- Status may report malformed header, short packet, or length mismatch conditions.

## Parameters and Configuration Knobs

- DATA_WIDTH sets payload width.
- META_WIDTH sizes extracted sideband fields.
- MAX_PACKET_LEN sizes beat and byte counters.
- DROP_BAD_PACKET selects drop versus forward-with-error policy.
- OUTPUT_MODE chooses raw payload only or payload plus decoded metadata.

## Internal Architecture and Dataflow

The module is normally a small parser FSM with header storage, beat counters, and payload forwarding logic. The hard part is staying boundary-correct under backpressure and under malformed traffic rather than merely moving data.

## Clocking, Reset, and Timing Assumptions

The datapath is typically synchronous. Reset must clear any partial packet state. Header decode and payload forwarding must remain consistent even if ready toggles in the middle of a packet.

## Latency, Throughput, and Resource Considerations

A good design sustains one beat per cycle through payload body transfer. Cost comes from small buffers, decode logic, and counters. Latency depends on whether header fields must be collected before payload emission begins.

## Verification Strategy

- Stress random backpressure while checking boundary preservation.
- Inject malformed, truncated, and maximum-length packets.
- Scoreboard decoded metadata against a software packet model.
- Check that bad-packet policy never leaks partial stale state into the next packet.

## Integration Notes and Dependencies

depacketizer usually sits before packet_fifo, stream FIFO stages, and protocol-independent payload blocks. It works best when the library uses one normalized packet-sideband convention.

## Edge Cases, Failure Modes, and Design Risks

- Malformed-packet policy must be explicit or software and hardware will disagree.
- Boundary bugs often appear only when stalls land on header or tail beats.
- Length counters and explicit markers need a documented precedence rule.

## Related Modules In This Domain

- packetizer
- packet_fifo
- stream_fifo
- stream_demux

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Depacketizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
