# PTP Timestamp Unit

## Overview

The PTP timestamp unit captures, inserts, and correlates precise time values for packets participating in IEEE 1588 or similar time-distribution schemes. It allows packet paths to measure egress and ingress events at deterministic points rather than approximating time in software.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Time synchronization is only as good as the accuracy of packet event timestamps. If transmit and receive times are sampled too late, too early, or inconsistently across packet paths, servo algorithms inherit systematic error. This module defines exact hardware capture points and provides the metadata plumbing needed to associate timestamps with specific packets.

## Typical Use Cases

- Timestamping Sync, Delay_Req, and related PTP messages at MAC-adjacent boundaries.
- Providing accurate network event time for distributed measurement or industrial-control systems.
- Supporting one-step or two-step timestamp workflows in custom timing appliances.

## Interfaces and Signal-Level Behavior

- Packet side usually receives parse metadata that identifies timestamp-eligible packets and emits timestamps or correction-field updates tied to packet identifiers.
- Time side connects to a free-running nanosecond or sub-nanosecond timebase, often disciplined elsewhere in the design.
- Control and status interfaces configure capture policy, timestamp format, and counters for missed or filtered events.

## Parameters and Configuration Knobs

- Timestamp width, fractional-time support, ingress and egress capture points, and one-step versus two-step support.
- Depth of association queues that match captured timestamps back to packet metadata.
- Filtering options for protocol type, port identity, or event message class.

## Internal Architecture and Dataflow

The unit typically taps packet flow at carefully chosen points near the MAC or PHY adaptation boundary, latches the current time when a packet crosses that point, and then attaches or stores the result using packet identifiers. Some implementations update packet correction fields inline for one-step operation, while others publish timestamps to software or servo logic for later follow-up frames. Queueing and correlation logic are essential because the packet stream and the software control path may not run in lockstep.

## Clocking, Reset, and Timing Assumptions

Accurate timestamps require a stable timebase and a clearly documented capture point relative to frame serialization. Reset must align timestamp queues with packet identifiers so stale capture records are never associated with new packets after a flush.

## Latency, Throughput, and Resource Considerations

The block handles modest metadata bandwidth relative to the packet stream, but it must do so without adding avoidable latency to the main datapath. Resource use is mostly timestamp storage, queueing, and packet-correlation logic.

## Verification Strategy

- Verify ingress and egress capture events against a reference model using known packet timing.
- Check packet-to-timestamp association under backpressure, filtered traffic, and bursts of timestamp-eligible frames.
- Exercise one-step correction updates and ensure non-PTP packets bypass the unit cleanly.

## Integration Notes and Dependencies

The timestamp unit depends on parsers that can recognize timing packets and on a disciplined time counter elsewhere in the design. Integration should state exactly where capture occurs, whether timestamps are in MAC, PHY, or application time, and how servo software retrieves or consumes them.

## Edge Cases, Failure Modes, and Design Risks

- A vague definition of the capture point can render all timestamps unusable for precise synchronization.
- Association queues that overflow under burst traffic may silently drop timing information.
- If the timebase can step discontinuously, packet timestamp consumers need explicit notification.

## Related Modules In This Domain

- timestamp_counter
- ethernet_mac
- udp_stack

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PTP Timestamp Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
