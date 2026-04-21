# Ethernet MAC

## Overview

The Ethernet MAC converts internal packet streams into compliant Ethernet frames on transmit and performs the inverse transformation on receive. It is the boundary where packetized application traffic meets link-layer framing, addressing, frame check sequences, and media-specific timing expectations.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Raw packet payloads are not enough to operate on Ethernet. A production path must handle destination and source MAC fields, frame length rules, padding, FCS generation or checking, inter-frame gap management, and receive filtering. This module packages those behaviors into a reusable link-layer endpoint.

## Typical Use Cases

- Terminating standard Ethernet links for control, telemetry, or sensor streaming appliances.
- Providing a reusable MAC layer under ARP, IPv4, UDP, or lightweight TCP hardware stacks.
- Supplying a packet interface for bridges, recorders, traffic generators, or timestamping systems.

## Interfaces and Signal-Level Behavior

- Fabric side typically presents packet streams with start and end markers, byte enables, and optional sideband metadata such as priority or timestamps.
- PHY side may expose GMII, RGMII, XGMII, or a simplified internal PCS-facing stream depending on speed grade.
- Statistics outputs often count good frames, CRC errors, runt frames, giant frames, drops, pause handling, and filter hits.

## Parameters and Configuration Knobs

- Supported speed set, minimum and maximum frame length rules, padding enable, and CRC insertion or verification settings.
- Address filtering options such as promiscuous mode, unicast match tables, multicast hash, or VLAN awareness.
- Timestamp sideband support and buffering depth on transmit and receive paths.

## Internal Architecture and Dataflow

Transmit logic accepts packet data, inserts MAC header fields if they are not already present, pads short frames when required, computes the FCS, and enforces inter-frame gap timing before handing data to the physical interface. Receive logic detects frame boundaries, strips or preserves trailers according to configuration, checks the FCS, and classifies or filters frames before publishing them upstream. Many designs also include small FIFOs to absorb burst mismatches between the fabric and the link.

## Clocking, Reset, and Timing Assumptions

The MAC assumes the physical coding or transceiver side meets its timing contract and that higher-level packet generators provide sensible length and metadata. Reset should flush partial frames and leave both transmit and receive paths in an idle state before traffic resumes.

## Latency, Throughput, and Resource Considerations

A good MAC can sustain line rate continuously for minimum-sized or maximum-sized frames depending on interface width. Resource usage is moderate and mainly shaped by FIFOs, address filtering features, and timestamp support rather than heavy arithmetic.

## Verification Strategy

- Run transmit and receive tests with minimum, maximum, VLAN-tagged, and malformed frames.
- Verify FCS insertion and checking, inter-frame gap behavior, padding, filtering, and statistics counters.
- Stress backpressure and clock-rate mismatches between packet fabric and PHY-side interfaces.

## Integration Notes and Dependencies

The MAC is the anchor for most network stacks, so interface conventions around whether headers arrive prebuilt or are synthesized internally must be documented clearly. Integration should also define how timestamps, PTP events, pause handling, and PHY link status are propagated into software or downstream logic.

## Edge Cases, Failure Modes, and Design Risks

- Frame-length accounting errors can produce packets that look fine internally but are dropped by peers.
- Misunderstood byte ordering or trailer stripping can break higher-level protocol parsers.
- A MAC without enough buffering may pass simulation and still drop bursts under real traffic contention.

## Related Modules In This Domain

- arp_engine
- udp_stack
- ptp_timestamp_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Ethernet MAC module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
