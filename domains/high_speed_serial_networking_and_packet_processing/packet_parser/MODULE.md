# Packet Parser

## Overview

The packet parser is the generic header-inspection front end for streaming network and transport pipelines. It identifies packet boundaries, extracts selected fields from one or more protocol layers, and emits normalized metadata that downstream engines can use without rescanning the byte stream.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Once packets enter a high-throughput stream, only a few blocks should need to inspect the raw bytes directly. Without a shared parser, every consumer duplicates offset calculations, boundary checks, and malformed-packet handling. This module centralizes those responsibilities and turns protocol bytes into structured packet metadata.

## Typical Use Cases

- Extracting Ethernet, VLAN, IP, and transport-layer fields for classification or routing.
- Preparing checksum, DMA, or timestamping engines with offsets and packet-length metadata.
- Building flexible capture or telemetry paths where the same packet stream feeds several specialized consumers.

## Interfaces and Signal-Level Behavior

- Input is typically a ready-valid packet stream with byte enables and explicit start and end of packet markers.
- Output combines pass-through packet data with parsed metadata such as protocol type, header offsets, lengths, and error flags.
- Configuration inputs select which protocols to inspect, how much header depth to tolerate, and which fields should be surfaced.

## Parameters and Configuration Knobs

- Datapath width, parse depth, supported protocol stack combinations, and metadata record width.
- Behavior on malformed packets, short packets, or unsupported encapsulations.
- Optional stripping mode, packet classification tags, and checksum-assist field generation.

## Internal Architecture and Dataflow

A robust parser walks the packet in stages, recognizing one header layer at a time and carrying forward alignment and length context for the next stage. The design often includes a small state machine plus field extractors that assemble multi-byte values across beat boundaries. Good implementations never lose track of packet boundaries even if parsing stops early because the rest of the packet still has to be forwarded, dropped, or mirrored consistently.

## Clocking, Reset, and Timing Assumptions

The parser assumes the upstream stream preserves byte order and packet boundaries exactly. If it supports only a subset of encapsulations, unsupported packets should be tagged explicitly rather than allowing downstream blocks to infer ambiguous defaults.

## Latency, Throughput, and Resource Considerations

Throughput should remain one beat per cycle for ordinary packets. Latency grows with the number of protocol layers inspected and with any buffering required to collect multi-byte fields that cross datapath boundaries.

## Verification Strategy

- Check field extraction on aligned and unaligned headers across several datapath widths.
- Inject malformed, truncated, or unexpectedly encapsulated packets to confirm parse-failure policy.
- Verify metadata stays attached to the correct packet when backpressure occurs mid-parse.

## Integration Notes and Dependencies

The parser is often the first shared metadata producer in a packet path, so interface contracts matter. Every downstream consumer should rely on the same offset and protocol fields from this block rather than attempting private reinterpretation of the raw packet stream.

## Edge Cases, Failure Modes, and Design Risks

- A single offset bug can mislead many downstream modules at once because they all trust the parser.
- If parse-failure tagging is not mandatory, consumers may treat unparsed fields as valid defaults.
- Metadata buffering and packet buffering must remain aligned under stalls or the whole pipeline becomes nondeterministic.

## Related Modules In This Domain

- ipv6_parser
- checksum_offload
- vlan_tagger

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Packet Parser module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
