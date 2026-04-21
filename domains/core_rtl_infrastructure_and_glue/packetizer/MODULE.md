# Packetizer

## Overview

packetizer wraps payload and metadata into a normalized framed representation suitable for transport, buffering, or logging. It is the complement of depacketizer.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Transport-facing logic usually needs headers, boundaries, tags, or lengths that payload blocks do not care about. packetizer isolates that concern and keeps framing policy consistent.

## Typical Use Cases

- Add headers and boundary markers before a transport block.
- Turn internal transactions into packet records.
- Prepare payloads for packet_fifo or protocol wrappers.

## Interfaces and Signal-Level Behavior

- Ingress accepts payload data plus local transaction or metadata controls.
- Egress produces framed data with start, end, length, type, or error sidebands.
- Status may report malformed upstream sequencing or inability to complete a packet.

## Parameters and Configuration Knobs

- DATA_WIDTH sizes payload.
- HEADER_MODE selects fixed, computed, or sideband-only headers.
- MAX_PACKET_LEN sizes counters.
- AUTO_CLOSE_EN defines behavior on unexpected upstream termination.
- TRAILER_EN reserves support for trailers or integrity fields.

## Internal Architecture and Dataflow

packetizer generally uses a small control FSM, metadata registers, and length tracking. The key detail is sequencing header, payload, and optional trailer correctly under backpressure.

## Clocking, Reset, and Timing Assumptions

Reset returns the module to an idle state with no partial frame in progress. If packet length must be known before emission, buffering rules need to be documented clearly.

## Latency, Throughput, and Resource Considerations

Payload throughput can often reach one beat per cycle once a packet is active. Latency depends on header preparation and any need to precompute length.

## Verification Strategy

- Check single-beat and long packets.
- Exercise stalls in header, body, and trailer phases.
- Verify malformed upstream command sequences are handled deterministically.
- Compare emitted metadata against a packet construction model.

## Integration Notes and Dependencies

packetizer typically feeds packet_fifo, protocol wrappers, and memory recorders. It works best when all packet-aware blocks share one sideband vocabulary.

## Edge Cases, Failure Modes, and Design Risks

- Header policy that is not explicit leads to downstream ambiguity.
- Length fields must stay synchronized with actual payload count.
- Packet abort behavior is easy to under-document and hard to debug later.

## Related Modules In This Domain

- depacketizer
- packet_fifo
- gearbox
- width_converter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Packetizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
