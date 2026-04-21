# VLAN Tagger

## Overview

The VLAN tagger inserts, removes, or inspects IEEE 802.1Q style VLAN tags on Ethernet frames so packet paths can classify or segregate traffic by virtual LAN identifier and priority. It provides a focused link-layer adaptation service without forcing every MAC or parser consumer to manipulate tag fields directly.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Tagged and untagged frames must coexist cleanly in many embedded Ethernet systems. Without a dedicated block, packet generators and parsers duplicate EtherType rewriting, tag offset handling, and priority extraction. This module standardizes tag manipulation and policy around VLAN-aware traffic.

## Typical Use Cases

- Inserting VLAN IDs and priorities on outbound control or TSN traffic.
- Stripping or classifying inbound tagged frames before application-level processing.
- Bridging between VLAN-aware network segments and internally simpler packet consumers.

## Interfaces and Signal-Level Behavior

- Input side accepts Ethernet frames plus metadata requesting insert, preserve, strip, or classify actions.
- Output side emits updated frames and sideband fields such as VLAN ID, PCP priority, drop eligibility, and tag-present status.
- Control inputs configure allowed VLAN IDs, default tagging policy, and behavior for unexpected or nested tags.

## Parameters and Configuration Knobs

- Support for single-tag only versus optional stacked tags, default VLAN insertion policy, and metadata widths.
- Whether the block is transmit-only, receive-only, or bidirectional.
- Priority-remap options and handling of untagged frames on VLAN-enforced ports.

## Internal Architecture and Dataflow

The tagger edits the Ethernet header region by inserting or removing the four-byte VLAN tag field, updating EtherType placement, and propagating parsed VLAN metadata alongside the frame. In classification mode it may leave payload untouched while extracting PCP and VID fields for downstream schedulers. Since the tag sits near the start of the frame, the block often needs a small header buffer to rewrite early bytes before releasing the stream.

## Clocking, Reset, and Timing Assumptions

The block assumes clear packet boundaries and enough early buffering to rewrite headers without losing throughput. If stacked tags are unsupported, the module should explicitly classify double-tagged frames as errors or pass-through cases rather than guessing.

## Latency, Throughput, and Resource Considerations

Throughput can remain one beat per cycle after initial header staging, but the first few cycles of each frame may incur fixed latency while the tag decision is made. Resource use is small and mostly tied to header buffering and metadata handling.

## Verification Strategy

- Verify insert, strip, preserve, and classify paths for tagged and untagged frames.
- Check PCP and VID extraction, EtherType placement, and behavior on nested or malformed tags.
- Stress packet-boundary handling across different datapath widths so header rewriting never shifts payload bytes incorrectly.

## Integration Notes and Dependencies

This block often sits near the MAC boundary or just after packet parsing. Integration should define whether VLAN policy is centrally managed here or merely surfaced as metadata to schedulers such as the TSN shaper.

## Edge Cases, Failure Modes, and Design Risks

- Header rewrite logic can easily misplace EtherType and payload boundaries if byte-enable cases are incomplete.
- Implicit default tagging policy may hide configuration mistakes until traffic reaches a VLAN-enforced switch.
- Priority extraction must remain aligned with the actual on-wire tag or TSN scheduling decisions will be wrong.

## Related Modules In This Domain

- packet_parser
- tsn_shaper
- ethernet_mac

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the VLAN Tagger module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
