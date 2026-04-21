# Bus Crossbar

## Overview

bus_crossbar connects multiple masters to multiple targets, allowing several independent transactions to proceed concurrently when they do not contend for the same path. It is the scalable routing fabric of the control and memory-mapped plane.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

A single shared bus serializes all traffic. As systems grow, that quickly becomes a bottleneck. bus_crossbar provides structured parallelism while keeping routing, arbitration, and response return rules explicit.

## Typical Use Cases

- Connect several control or DMA masters to many peripherals and memories.
- Allow independent transactions to proceed concurrently to different targets.
- Centralize arbitration and target routing in a larger SoC fabric.

## Interfaces and Signal-Level Behavior

- Master-side interfaces carry requests, data, and response channels appropriate to the chosen bus style.
- Target-side interfaces receive only the transactions routed to them, often after local arbitration.
- Status may expose route occupancy, stalls, or fault conditions.

## Parameters and Configuration Knobs

- NUM_MASTERS and NUM_TARGETS size the fabric.
- ARBITRATION_POLICY selects target-local priority or fairness behavior.
- PIPELINE_CUTS allows timing stages between masters and targets.
- ID_REMAP_EN controls how source identity is preserved or remapped.
- ORDERING_MODE documents per-target and per-master ordering guarantees.

## Internal Architecture and Dataflow

A crossbar combines address decode or route selection, per-target arbitration, data steering, and response return paths. The essential architectural contract is who owns arbitration, how responses are matched back to masters, and what ordering guarantees survive through contention.

## Clocking, Reset, and Timing Assumptions

Masters and targets must agree on whether transaction IDs exist and whether responses may return out of issue order. Reset should clear route ownership and any in-flight response tracking state. A crossbar is not automatically coherent just because it is shared.

## Latency, Throughput, and Resource Considerations

Crossbars can improve concurrency dramatically, but their cost grows quickly with port count, width, and pipelining. Timing hot spots often appear in wide route steering and arbitration logic.

## Verification Strategy

- Exercise many-master, many-target traffic with and without contention.
- Verify per-target arbitration and response return routing.
- Check ordering guarantees under contention and out-of-order target behavior.
- Inject target stalls and errors while several flows are active.

## Integration Notes and Dependencies

bus_crossbar usually sits above decoders, local bridges, and target endpoints such as AXI-Lite slaves or APB bridges. It should document clearly whether it is optimized for control-plane simplicity or higher-throughput memory traffic.

## Edge Cases, Failure Modes, and Design Risks

- Ordering assumptions can break silently when several masters contend for one target.
- Response return bookkeeping becomes a major risk once concurrency grows.
- A large crossbar can become both an area and timing problem if pipelining is left too late.

## Related Modules In This Domain

- address_decoder
- axi4_master
- transaction_tracker
- interrupt_aggregator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bus Crossbar module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
