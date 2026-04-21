# IPv4 Router Block

## Overview

The IPv4 router block parses IPv4 headers, validates forwarding eligibility, applies simple routing decisions, and prepares packets for the next hop. It is aimed at embedded packet paths that need more than end-host behavior but less than a full software-defined router.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Forwarding IPv4 traffic requires more than stripping a header and re-emitting data. Packets must be checked for version, header length, TTL expiry, checksum validity, and destination policy before the correct next hop and output metadata are chosen. This module centralizes that decision path so forwarding behavior is explicit and testable.

## Typical Use Cases

- Implementing a small hardware forwarder between acquisition networks and host uplinks.
- Routing packets among internal virtual networks or accelerator islands with deterministic latency.
- Supporting appliances that only need a narrow set of IPv4 forwarding features in hardware.

## Interfaces and Signal-Level Behavior

- Ingress side usually accepts parsed or semi-parsed IPv4 packets with sideband metadata such as ingress port and destination lookup hints.
- Egress side emits forwarding decisions, decremented TTL fields, checksum-update requests, and next-hop metadata for ARP or MAC stages.
- Control-plane side configures route entries, default routes, policy exceptions, and counters for drops or forwarded traffic.

## Parameters and Configuration Knobs

- Route-table depth, longest-prefix-match implementation style, and whether multiple egress ports are supported.
- Optional checksum-rewrite assistance, fragmentation handling limits, and ICMP exception generation support.
- Counter widths and metadata fields used to tag packets with forwarding decisions.

## Internal Architecture and Dataflow

The block typically parses the IPv4 header fields needed for forwarding, performs a route-table lookup, checks TTL and checksum validity, and then updates header metadata before handing the packet to ARP resolution or a selected egress queue. Minimal variants may only support direct host routes and a default gateway. Richer designs add longest-prefix match structures, ACL-like policy checks, and exception signaling for control software.

## Clocking, Reset, and Timing Assumptions

This module assumes lower layers already validated Ethernet framing and provided contiguous packet boundaries. If fragmentation is not supported, the documentation and interface must say so clearly because forwarding behavior for fragmented packets changes system-level expectations.

## Latency, Throughput, and Resource Considerations

Lookup latency depends on the routing data structure, but datapath throughput can remain one packet beat per cycle once parsing is in flight. Area is driven more by route-table storage and update logic than by arithmetic.

## Verification Strategy

- Verify routing decisions for exact-match, prefix-match, default-route, and miss cases.
- Check TTL decrement, checksum-update interaction, and exception handling for invalid headers.
- Inject unsupported options or fragmented packets to confirm policy is explicit rather than accidental.

## Integration Notes and Dependencies

The router block usually depends on ARP resolution, checksum update support, and one or more output schedulers. Integrators should define whether route management is software controlled, whether packets are dropped or trapped on misses, and how control-plane exceptions are surfaced.

## Edge Cases, Failure Modes, and Design Risks

- Treating all IPv4 packets as forwardable without option or fragmentation policy can create hidden interoperability gaps.
- Incorrect TTL or checksum rewrite behavior may only surface after several forwarding hops.
- If route updates race in-flight lookups, packets may be tagged with stale next-hop metadata.

## Related Modules In This Domain

- arp_engine
- checksum_offload
- udp_stack

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the IPv4 Router Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
