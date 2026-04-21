# Register Slice

## Overview

register_slice adds pipeline registers to an interface so timing closes more easily while protocol semantics remain intact. It is the disciplined way to insert latency for timing relief.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Ad hoc register insertion often breaks handshake semantics or creates hidden bubbles. register_slice turns timing relief into a reusable, predictable interface primitive.

## Typical Use Cases

- Break a long valid-ready path.
- Create a floorplanning boundary between IP blocks.
- Insert a known latency stage into a bus or stream channel.

## Interfaces and Signal-Level Behavior

- Inputs and outputs mirror the same protocol.
- Handshake logic preserves lossless transfer under stalls.
- Optional status may expose whether the slice is empty or occupied.

## Parameters and Configuration Knobs

- DATA_WIDTH and SIDEBAND_WIDTH size payload.
- STAGES sets pipeline depth.
- FULL_HANDSHAKE mode registers both forward and reverse paths.
- FORWARD_ONLY mode registers only forward signals.
- BYPASS_EN allows zero-latency mode when timing is easy.

## Internal Architecture and Dataflow

The block is usually one or more payload registers plus handshake control that decides when data advances and when it must be held. For full ready-valid behavior, the reverse path is as important as the forward data path.

## Clocking, Reset, and Timing Assumptions

The slice is local to one clock domain. Reset clears any stored valid data. All sidebands associated with a beat must be pipelined alongside the payload.

## Latency, Throughput, and Resource Considerations

Latency is fixed by the configured stage count. A good register_slice still supports full throughput once the pipeline is filled. Cost scales with payload width and control complexity.

## Verification Strategy

- Check no data is lost through long random stall patterns.
- Verify bubble behavior and steady-state throughput.
- Confirm reset clears stored valid state.
- Compare input and output ordering exactly.

## Integration Notes and Dependencies

register_slice commonly surrounds FIFOs, converters, muxes, and wide arithmetic blocks. It should be part of interface architecture rather than only a late timing patch.

## Edge Cases, Failure Modes, and Design Risks

- Partial registration of a protocol can be worse than none at all.
- Added cycles must be visible to upstream timeout and control logic.
- Unpipelined sidebands are a classic source of silent corruption.

## Related Modules In This Domain

- skid_buffer
- stream_fifo
- width_converter
- stream_mux

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Register Slice module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
