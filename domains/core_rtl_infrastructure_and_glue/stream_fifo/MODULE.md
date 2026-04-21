# Stream FIFO

## Overview

stream_fifo is a same-clock elastic queue for ready-valid traffic. It decouples producer and consumer timing, absorbs short bursts, and simplifies throughput smoothing inside one clock domain.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Tightly coupled streams create long timing paths and brittle throughput behavior. stream_fifo introduces controlled elasticity without the CDC burden of an asynchronous FIFO.

## Typical Use Cases

- Buffer between producer and consumer stages in the same clock domain.
- Absorb bursts before a slower shared resource.
- Create a clean timing boundary with bounded storage.

## Interfaces and Signal-Level Behavior

- Ingress and egress use valid, ready, and data, with optional sidebands.
- Status can include full, empty, almost full, almost empty, and occupancy.
- Optional packet sidebands can be stored by widening the word.

## Parameters and Configuration Knobs

- DATA_WIDTH and DEPTH size the queue.
- ALMOST_FULL_THRESHOLD and ALMOST_EMPTY_THRESHOLD add watermarks.
- OUTPUT_REG selects read timing style.
- RAM_STYLE hints at implementation mapping.
- COUNT_EN enables occupancy reporting.

## Internal Architecture and Dataflow

The block is normally a circular buffer with exact occupancy because both sides share a clock. The main behavioral questions are read timing style and boundary conditions at empty and full.

## Clocking, Reset, and Timing Assumptions

Reset returns the FIFO to empty. All metadata that belongs to a beat must be stored and replayed with it. The module is not a CDC primitive.

## Latency, Throughput, and Resource Considerations

A good implementation supports one enqueue and one dequeue per cycle simultaneously. Resource cost depends on depth, width, and storage style. Latency depends on whether the output is fall-through or registered.

## Verification Strategy

- Check full and empty boundaries under simultaneous read and write.
- Stress long random traffic with stalls.
- Verify occupancy counters and watermarks.
- Confirm sideband alignment if metadata is stored.

## Integration Notes and Dependencies

stream_fifo is a default elasticity primitive around muxes, converters, and arithmetic pipelines. It should be preferred over skid_buffer when actual short-term storage is needed.

## Edge Cases, Failure Modes, and Design Risks

- Off-by-one errors around full or empty remain common.
- Different storage styles may behave differently on read-during-write if the contract is not explicit.
- Very small FIFOs can add latency where a skid buffer would have sufficed.

## Related Modules In This Domain

- async_fifo
- packet_fifo
- skid_buffer
- register_slice

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Stream FIFO module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
