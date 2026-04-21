# DDR Scheduler Frontend

## Overview

The DDR scheduler frontend arbitrates and shapes memory requests headed toward an external DDR controller so latency-sensitive and bandwidth-hungry clients can share the same channel predictably. It is a policy layer that sits above the PHY or controller and below application-specific memory users.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

Uncoordinated DDR requests can thrash row locality, starve urgent clients, and waste burst opportunities. A frontend scheduler is needed to buffer, classify, and order requests before they hit the controller. This module turns many masters into a disciplined stream of memory transactions with explicit quality-of-service behavior.

## Typical Use Cases

- Sharing one DDR channel among video buffers, DMA engines, descriptor fetchers, and CPU traffic.
- Improving burst efficiency by reordering or grouping requests within controlled limits.
- Applying priority or bandwidth caps to latency-sensitive storage and streaming workloads.

## Interfaces and Signal-Level Behavior

- Upstream side accepts read and write requests from multiple clients with address, burst length, priority, and optional stream identifiers.
- Downstream side emits scheduled memory commands toward a DDR controller interface and receives read returns for demultiplexing back to requestors.
- Control side configures arbitration policy, age limits, reorder windows, and performance counters.

## Parameters and Configuration Knobs

- Number of clients, queue depth per client, burst-size support, and arbitration algorithm.
- Address-map awareness for bank, row, and column optimization plus reorder-window limits.
- Return-data buffering depth and support for QoS classes or bandwidth reservation.

## Internal Architecture and Dataflow

The scheduler typically maintains per-client queues, global selection logic, and optional row- or bank-aware scoring that prefers requests likely to hit open pages or minimize turnaround penalties. It may also enforce fairness by aging requests or reserving service opportunities for critical clients. Read return paths track ownership so data is routed back to the correct requester even after downstream reordering.

## Clocking, Reset, and Timing Assumptions

The module assumes the downstream DDR controller accepts requests in a defined order and may expose backpressure. Reset and recovery must invalidate any in-flight reorder bookkeeping so read responses cannot be misdelivered after the fabric restarts.

## Latency, Throughput, and Resource Considerations

A strong scheduler can dramatically improve effective DDR throughput and tail latency, but the gains depend on workload locality and request diversity. Area scales with queueing and scoreboarding rather than arithmetic.

## Verification Strategy

- Verify fairness, starvation bounds, and QoS behavior across mixed client traffic.
- Check reorder-window limits and read-return ownership when requests complete out of issue order.
- Measure behavior under pathological address patterns that defeat row locality or force many direction changes.

## Integration Notes and Dependencies

This block is most effective when upstream clients provide useful burst and priority metadata. Designers should document what ordering guarantees remain visible to each client, especially if software assumes strongly ordered memory responses.

## Edge Cases, Failure Modes, and Design Risks

- Aggressive reordering can violate hidden client assumptions about completion order.
- Fairness bugs may only appear under sustained multi-client saturation.
- If bank or row mapping assumptions do not match the actual controller layout, the scheduler may optimize the wrong behavior.

## Related Modules In This Domain

- ddr_ecc_frontend
- read_prefetch_engine
- writeback_cache

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DDR Scheduler Frontend module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
