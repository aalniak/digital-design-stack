# Width Converter

## Overview

width_converter adapts data width between adjacent interfaces while preserving ordering, alignment, and handshake semantics. It is the generic width-adaptation primitive when protocol meaning is already shared.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Different native beat widths create recurring integration bugs around byte order, partial words, and boundary propagation. width_converter captures those rules once instead of letting every pair of blocks solve them differently.

## Typical Use Cases

- Bridge a narrow peripheral stream to a wide memory-facing path.
- Split wide words for a narrow consumer without redesigning both ends.
- Normalize widths between reusable blocks that otherwise share the same protocol.

## Interfaces and Signal-Level Behavior

- Ingress and egress generally share the same handshake style.
- Optional sidebands include keep, first, last, or source tags.
- The module must define how incomplete final groups are represented.

## Parameters and Configuration Knobs

- IN_WIDTH and OUT_WIDTH set the ratio.
- BYTE_ENABLE_EN supports partial words.
- BOUNDARY_MODE defines packet-marker handling.
- BUFFER_DEPTH sizes internal partial-state storage.
- ALIGNMENT_MODE defines lane ordering.

## Internal Architecture and Dataflow

For widening, the block accumulates several narrow inputs before emitting one wide output. For narrowing, it sequences slices of a wide input across several output beats. Correct partial-state handling is the main challenge.

## Clocking, Reset, and Timing Assumptions

Reset clears any partial packed word. If the stream is packetized, the policy for a packet ending on a non-natural width boundary must be clear.

## Latency, Throughput, and Resource Considerations

Steady-state throughput depends on ratio and output timing style, but a good design can usually sustain one beat per active side per cycle. Cost is driven by wide registers, counters, and sideband handling.

## Verification Strategy

- Check byte ordering in both widening and narrowing modes.
- Exercise partial trailing words and packet boundaries.
- Stress stalls on both sides while internal partial state exists.
- Scoreboard end-to-end reconstruction against a software model.

## Integration Notes and Dependencies

width_converter appears beside FIFOs, memory adaptors, packetizers, and gearboxes. It works best when the library uses one consistent alignment convention.

## Edge Cases, Failure Modes, and Design Risks

- Byte-order and partial-word rules are easy to get wrong and hard to spot visually.
- Sidebands must stay aligned with payload through every internal state.
- A gearbox-like feature creep can make the module harder to reason about if its scope is not kept clear.

## Related Modules In This Domain

- gearbox
- stream_fifo
- register_slice
- packetizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Width Converter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
