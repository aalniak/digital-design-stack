# TCP Offload Lite

## Overview

TCP Offload Lite implements a deliberately bounded subset of TCP transport behavior in hardware so embedded designs can terminate or originate simple reliable streams without a full software TCP stack. The emphasis is on predictable, documentable behavior rather than exhaustive protocol coverage.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

TCP offers flow control, sequencing, retransmission, and connection management, but implementing the entire protocol in hardware is expensive and risky. Some systems only need a narrow operational envelope such as one or a few established streams with limited option support. This module captures that smaller target honestly, making the supported subset explicit.

## Typical Use Cases

- Serving a small control or telemetry stream directly from hardware.
- Receiving command streams from a host in environments where firmware assistance is limited.
- Providing a lightweight reliable transport for bench tools and embedded appliances.

## Interfaces and Signal-Level Behavior

- Application side usually exposes a byte or packet stream interface with connection status, flow-control visibility, and error indications.
- Network side exchanges parsed TCP segments and emit-ready metadata through IP and MAC layers.
- Control side configures ports, connection policy, retransmission limits, and the supported option set.

## Parameters and Configuration Knobs

- Maximum simultaneous connections, receive and transmit window sizes, retransmission timers, and sequence-number storage depth.
- Support limits for SYN handling, FIN closure, MSS negotiation, and selective options if any.
- Buffer sizes and whether checksum work is delegated to a separate checksum engine.

## Internal Architecture and Dataflow

A lightweight TCP offload block typically includes a small connection table, sequence and acknowledgement tracking, retransmission timers, window bookkeeping, and state machines for a reduced subset of the TCP connection lifecycle. Payload buffering and application backpressure handling are critical because TCP reliability semantics depend on clear ownership of what data has been accepted, transmitted, acknowledged, or retried.

## Clocking, Reset, and Timing Assumptions

The design should document its supported subset with unusual honesty, including any unsupported options, limited connection states, or simplified congestion assumptions. Reset and error handling must retire all connection state cleanly because partially preserved sequence numbers are disastrous.

## Latency, Throughput, and Resource Considerations

Performance depends heavily on buffer sizing and the allowed number of outstanding unacknowledged bytes. The logic cost is meaningful because timers, sequence tracking, and retransmission state are more complex than UDP or raw packet paths.

## Verification Strategy

- Verify connection establishment, steady-state transfer, retransmission, duplicate acknowledgements, and orderly teardown for the supported subset.
- Inject out-of-order segments, checksum failures, zero-window conditions, and timeout events.
- Check unsupported option or state transitions produce explicit failure behavior rather than undefined operation.

## Integration Notes and Dependencies

This module depends on parsers, checksum support, timers, and some policy layer that defines which peers or ports are allowed. Integration should make sure software and users understand the supported TCP subset so they do not assume full interoperability with arbitrary Internet stacks.

## Edge Cases, Failure Modes, and Design Risks

- Calling a narrow implementation TCP without clearly documenting the limits invites interoperability surprises.
- Buffer ownership bugs can create duplicated or lost payload while headers still look valid.
- Retransmission timers tied to unstable clocks or paused timebases can break reliability in subtle ways.

## Related Modules In This Domain

- udp_stack
- checksum_offload
- packet_parser

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TCP Offload Lite module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
