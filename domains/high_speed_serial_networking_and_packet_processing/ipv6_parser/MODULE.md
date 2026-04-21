# IPv6 Parser

## Overview

The IPv6 parser extracts routing, transport, and policy-relevant metadata from IPv6 packets without forcing downstream blocks to inspect raw header bytes repeatedly. It is optimized for streaming operation on packet fabrics where the parser may only see each byte once.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

IPv6 headers are wider than IPv4 and may be followed by extension headers that complicate transport-layer discovery. If every consumer must reinterpret those fields independently, the design becomes inconsistent and expensive. This module creates one authoritative parsed view of the packet so later checksum, routing, filtering, and DMA logic can act on normalized metadata.

## Typical Use Cases

- Front-ending hardware UDP or control-plane stacks that accept IPv6 traffic.
- Extracting addresses, next-header information, and hop-limit state for packet filters or forwarders.
- Feeding timestamping, traffic classification, or telemetry pipelines with normalized IPv6 metadata.

## Interfaces and Signal-Level Behavior

- Input side consumes packet streams with packet-boundary markers and optional sideband ingress metadata.
- Output side emits parsed fields such as source and destination addresses, next header, traffic class, flow label, payload length, and parse status.
- Optional side outputs may expose extension-header progress, drop reasons, or transport-layer offsets for downstream engines.

## Parameters and Configuration Knobs

- Maximum number of extension headers to inspect, supported next-header types, and parser pipeline depth.
- Address and metadata output width, byte-enable handling, and drop or trap policy on unsupported options.
- Whether the parser only classifies or also strips header bytes for payload-aligned downstream paths.

## Internal Architecture and Dataflow

The parser steps through the fixed 40-byte base header first, then optionally walks a bounded chain of extension headers until it finds an upper-layer protocol or reaches a configured inspection limit. Parsed fields are accumulated into a metadata record that stays aligned with the packet stream. Designs that must preserve throughput typically keep the packet flowing while the metadata pipeline advances in parallel, only stalling on rare unsupported patterns.

## Clocking, Reset, and Timing Assumptions

Because extension-header processing can be expensive, the implementation must state clearly which header types are recognized and when packets are passed through, dropped, or trapped for software. Reset should clear any in-progress parse state so one packet cannot leak its partially decoded extension context into the next.

## Latency, Throughput, and Resource Considerations

The base-header path is straightforward, but extension-header walking can add latency or buffering if many chained headers are allowed. Area cost scales with how much flexible header inspection the design supports and whether address fields are stored in full or reduced into compact metadata.

## Verification Strategy

- Verify fixed-header parsing, address extraction, and next-header identification on ordinary IPv6 packets.
- Exercise extension-header chains, unsupported types, and oversized or truncated packets to confirm policy behavior.
- Check that metadata offsets provided to downstream transport engines remain correct after any parsed extension headers.

## Integration Notes and Dependencies

This parser generally feeds UDP, TCP, routing, or policy blocks that do not want to re-scan headers. Integration should specify whether checksum engines receive transport offsets from this block and how parse failures are surfaced to counters, traps, or drop paths.

## Edge Cases, Failure Modes, and Design Risks

- Extension-header corner cases can make transport-layer offsets wrong even when the base header looks valid.
- If unsupported headers are silently treated as payload, downstream protocol blocks may misclassify traffic.
- Wide address metadata can create backpressure if downstream consumers were sized for IPv4-like field widths.

## Related Modules In This Domain

- packet_parser
- udp_stack
- checksum_offload

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the IPv6 Parser module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
