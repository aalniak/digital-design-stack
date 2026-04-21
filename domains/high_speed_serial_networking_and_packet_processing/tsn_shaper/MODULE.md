# TSN Shaper

## Overview

The TSN shaper schedules packet release according to time-sensitive networking traffic rules so selected streams experience bounded latency and controlled interference from best-effort traffic. It is most relevant in industrial, automotive, and mixed-criticality Ethernet systems.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Not all Ethernet traffic can simply contend in a shared queue if some flows require bounded latency or phase-aligned delivery. TSN-style shaping introduces time-aware gates, credit behavior, or class-based scheduling to reserve transmission opportunities. This module packages that policy logic so the MAC sees a disciplined packet release stream instead of unscheduled contention.

## Typical Use Cases

- Enforcing deterministic egress windows for control-plane or motion-control traffic.
- Separating scheduled and best-effort traffic on shared Ethernet links.
- Experimenting with TSN-aware packet scheduling in research testbeds or industrial prototypes.

## Interfaces and Signal-Level Behavior

- Ingress side accepts packets tagged with traffic class, priority, or stream identity.
- Egress side forwards packets to the MAC only when the current gate or credit policy permits transmission.
- Time and control interfaces configure schedules, gate states, cycle boundaries, and counters for missed windows or dropped packets.

## Parameters and Configuration Knobs

- Number of traffic classes, queue depth per class, and selected shaping method such as time-aware gating or credit-based shaping.
- Schedule granularity, timebase width, and guard-band policy.
- Drop versus defer behavior when a packet cannot fit in the remaining transmit window.

## Internal Architecture and Dataflow

A TSN shaper usually includes per-class queues, a scheduler driven by a global timebase or credit counters, and admission logic that determines which packet may enter the MAC next. Time-aware variants open and close gates according to a repeating schedule, while credit-based variants accumulate and consume transmission credit based on class rules. The design must account for packet serialization time, not just abstract packet readiness, when deciding whether a frame can start.

## Clocking, Reset, and Timing Assumptions

Deterministic shaping requires a stable timebase and a known link speed so transmission duration can be predicted accurately. Reset or schedule updates must transition carefully because changing gates mid-frame can violate both protocol and traffic guarantees.

## Latency, Throughput, and Resource Considerations

The shaper should sustain full link utilization when traffic mix and schedule allow. Area cost rises with queue count, schedule storage, and time-comparison logic rather than arithmetic.

## Verification Strategy

- Verify gate behavior, guard-band enforcement, and class selection over several schedule cycles.
- Check packet fits, overruns, and defer or drop behavior when windows are too short.
- Exercise mixed best-effort and scheduled traffic to confirm latency guarantees are not eroded by backpressure.

## Integration Notes and Dependencies

This block usually sits directly in front of the Ethernet MAC and depends on packet classification upstream plus a synchronized timebase. Integrators should document how schedule updates are applied, how mis-scheduled packets are reported, and whether software can inspect per-class backlog in real time.

## Edge Cases, Failure Modes, and Design Risks

- Ignoring frame serialization time leads to schedules that look valid on paper but overlap on the wire.
- Unsynchronized clocks across devices can undermine end-to-end TSN guarantees even if local shaping is correct.
- If queue priorities are unclear, best-effort traffic may starve or scheduled traffic may miss windows under load.

## Related Modules In This Domain

- ptp_timestamp_unit
- ethernet_mac
- vlan_tagger

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TSN Shaper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
