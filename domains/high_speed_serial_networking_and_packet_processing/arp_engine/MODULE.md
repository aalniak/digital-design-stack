# ARP Engine

## Overview

The ARP engine resolves IPv4 addresses to link-layer MAC addresses and maintains the short-lived mapping state required for Ethernet-attached systems. It shields the rest of the packet stack from broadcast ARP traffic, cache aging rules, and retry policy so transmit pipelines can request address resolution through a simple lookup interface.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Any IPv4 endpoint on Ethernet must translate next-hop IP addresses into destination MAC addresses before it can emit frames. Doing that translation ad hoc in software or scattered RTL creates latency, duplicate cache logic, and inconsistent handling of misses and gratuitous updates. This module centralizes request, reply, cache, and timeout behavior.

## Typical Use Cases

- Resolving destination MAC addresses for a hardware UDP or lightweight TCP pipeline.
- Maintaining a small ARP cache for embedded control-plane traffic without a full software network stack.
- Supporting laboratory traffic generators or packet capture instruments that need predictable network bring-up.

## Interfaces and Signal-Level Behavior

- Lookup side usually accepts an IPv4 address plus request-valid and returns hit, miss, or resolved MAC metadata.
- Packet side consumes incoming ARP frames from a parser and emits reply frames or cache updates into a transmit path.
- Management registers often expose local IP and MAC identity, cache contents, retry counters, and timeout statistics.

## Parameters and Configuration Knobs

- ARP cache depth, replacement policy, retry timing, and entry aging interval.
- Support for gratuitous ARP processing, proxy behavior, or static entry preload.
- Packet-side metadata width and whether requests can be queued or must be serviced one at a time.

## Internal Architecture and Dataflow

The engine typically combines a small associative or direct-mapped cache, packet decoders for ARP request and reply frames, and a control state machine that issues network requests when a lookup misses. Incoming valid replies update the cache, while requests targeting the local IP may trigger a generated response frame. The datapath is modest; the main design work lies in ordering lookups, retries, and stale-entry cleanup.

## Clocking, Reset, and Timing Assumptions

The module assumes the surrounding Ethernet stack already strips frame preamble and FCS, and that packet parsers provide valid ARP opcode and address fields. Reset should invalidate dynamic cache entries so stale mappings are never reused after restart.

## Latency, Throughput, and Resource Considerations

Area is primarily a function of cache size and buffering rather than arithmetic. Resolution latency on a hit is usually one or a few cycles; miss latency is dominated by network round-trip time and retry policy rather than local logic speed.

## Verification Strategy

- Verify cache hit, miss, update, aging, and replacement behavior under repeated lookups.
- Inject valid and malformed ARP requests and replies to confirm only appropriate packets affect local state.
- Check retry and timeout logic so unresolved destinations propagate clear failure status upstream.

## Integration Notes and Dependencies

The ARP engine normally lives between an IPv4 transmit path and an Ethernet MAC or packetizer. Integration should document whether software may inspect or override cache entries and how unresolved traffic is stalled, dropped, or retried at higher layers.

## Edge Cases, Failure Modes, and Design Risks

- Caches that never age entries can silently retain stale MAC addresses after topology changes.
- Poor coordination with the transmit scheduler can allow multiple redundant ARP requests for the same target.
- If gratuitous or unsolicited replies are accepted without policy, spoofed traffic may poison the cache.

## Related Modules In This Domain

- ipv4_router_block
- ethernet_mac
- udp_stack

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ARP Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
