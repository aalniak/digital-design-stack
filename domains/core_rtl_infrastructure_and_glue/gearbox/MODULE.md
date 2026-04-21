# Gearbox

## Overview

gearbox repacks a stream between different beat widths or symbol groupings while preserving ordering and framing semantics. It is a structural adaptation block for interfaces that agree on meaning but disagree on packing.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Width and grouping mismatches create a large class of off-by-one, byte-order, and boundary bugs. gearbox makes repacking behavior explicit and reusable.

## Typical Use Cases

- Adapt a narrow symbol stream to a wider payload path.
- Repack bytes or words between protocol and memory-facing blocks.
- Align beat grouping without forcing every adjacent block to understand every format.

## Interfaces and Signal-Level Behavior

- Ingress and egress usually both use valid-ready style flow control.
- Optional sidebands include keep, first, last, and error markers.
- Status may expose partial-buffer occupancy or flush conditions.

## Parameters and Configuration Knobs

- IN_WIDTH and OUT_WIDTH set the pack ratio.
- BYTE_ENABLE_EN supports partial final words.
- BOUNDARY_MODE defines packet-marker handling.
- ALIGNMENT_MODE defines lane ordering.
- BUFFER_DEPTH sets how much partial state may accumulate.

## Internal Architecture and Dataflow

A gearbox generally uses an accumulation register, fill counters, and shift logic. The tricky part is maintaining correct state through stalls and transaction boundaries, not the shifting itself.

## Clocking, Reset, and Timing Assumptions

Reset must clear any partial aggregate word. If packet boundaries exist, the module must define how incomplete trailing words are padded or flagged.

## Latency, Throughput, and Resource Considerations

Steady-state throughput can often reach one ingress beat and one egress beat per cycle, though startup and drain behavior depend on width ratio. Cost comes from registers, shifters, and sideband tracking.

## Verification Strategy

- Check byte order for every supported ratio.
- Exercise partial last-word cases.
- Stress backpressure on both sides with packet boundaries in awkward places.
- Verify that flush or reset does not leak stale partial data.

## Integration Notes and Dependencies

gearbox is often paired with width_converter, packetizer, and stream FIFOs. Consistent alignment conventions across the library are essential.

## Edge Cases, Failure Modes, and Design Risks

- Byte-order confusion is a common late-stage bug.
- Boundary handling on partial words is easy to underspecify.
- Partial internal state can be lost if stall behavior is not modeled carefully.

## Related Modules In This Domain

- width_converter
- packetizer
- depacketizer
- stream_fifo

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Gearbox module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
