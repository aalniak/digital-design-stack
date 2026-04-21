# Stream Demux

## Overview

stream_demux routes one input stream to one of several outputs while preserving handshake semantics and, when needed, packet atomicity. It is the reusable traffic-steering primitive for stream fan-out.

## Domain Context

In the Core RTL Infrastructure and Glue domain, modules are judged by how safely and predictably they connect larger blocks. They provide framing, arbitration, buffering, timing relief, and control plumbing that many other domains depend on.

## Problem Solved

Routing logic is easy to write badly: selection can change mid-transaction, backpressure can be sourced from the wrong output, and invalid routes can create silent drops. stream_demux makes that behavior explicit.

## Typical Use Cases

- Route commands or data to one of several internal consumers.
- Split a packet stream according to header decode.
- Steer control transactions based on address or type.

## Interfaces and Signal-Level Behavior

- Ingress uses a standard stream interface.
- Routing can come from a sideband, control input, or derived decode.
- Only the selected output should see valid activity and only its ready should control acceptance.

## Parameters and Configuration Knobs

- NUM_OUTPUTS sets fan-out.
- SELECT_WIDTH or ROUTE_MODE defines route encoding.
- HOLD_SELECTION_UNTIL_LAST preserves packet atomicity.
- DEFAULT_ROUTE defines behavior for unmapped selections.
- DROP_ON_INVALID chooses stall versus drop policy.

## Internal Architecture and Dataflow

The block gates valid and payload to one selected output while multiplexing the selected ready path back. Packet-aware versions latch the route at transaction start and hold it until completion.

## Clocking, Reset, and Timing Assumptions

All interfaces share one clock. Reset clears any held route state. If packet framing exists, the module must define whether selection is allowed to change every beat or only at boundaries.

## Latency, Throughput, and Resource Considerations

Throughput can reach one beat per cycle if route decode and ready fan-in are simple enough. Large fan-out may require pipelining or skid buffering on the selected path.

## Verification Strategy

- Verify only the selected output receives each beat.
- Check selected-ready feedback under stalls.
- Stress invalid route cases and confirm the documented policy.
- For packet mode, verify a route never changes mid-packet.

## Integration Notes and Dependencies

stream_demux is usually paired with packet parsing, stream_mux, and packet-aware buffering. It benefits from a single shared route-sideband convention.

## Edge Cases, Failure Modes, and Design Risks

- Mid-transaction selection changes can silently corrupt data.
- Invalid-route policy must be explicit or lost traffic will be hard to diagnose.
- Ready-path fan-in can become a timing issue for large output counts.

## Related Modules In This Domain

- stream_mux
- packetizer
- depacketizer
- register_slice

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Stream Demux module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
