# UDP Stack

## Overview

The UDP stack terminates or originates user datagrams over IP and Ethernet while keeping the transport layer intentionally simple. It is the natural hardware transport for telemetry, sensor streaming, control messages, and timing packets when low overhead matters more than reliability.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Even a simple datagram transport still requires port handling, length bookkeeping, checksum interaction, and integration with IP addressing and MAC resolution. Without a reusable block, each design reimplements these functions inconsistently. This module provides a clean datagram boundary between applications and lower network layers.

## Typical Use Cases

- Sending and receiving sensor data, timing traffic, or lab-control messages over Ethernet.
- Providing a simple packet I/O path for hardware accelerators and acquisition systems.
- Serving as the transport layer under PTP, discovery, or custom datagram protocols.

## Interfaces and Signal-Level Behavior

- Application side commonly exposes packetized payload streams with source or destination port metadata.
- Network side exchanges IP-layer metadata and packet payload with parsers, checksum engines, and MAC-facing blocks.
- Control registers configure local ports, filtering policy, checksum enable, and drop counters.

## Parameters and Configuration Knobs

- Supported port table depth, payload length limits, checksum insert and verify options, and buffering depth.
- Number of concurrent application channels and metadata fields used for dispatch.
- Whether the stack is endpoint-only or also assists forwarding or multicast reception.

## Internal Architecture and Dataflow

Transmit logic prepends UDP header fields, computes or requests checksum generation when enabled, and passes length and address metadata downward to the IP and Ethernet layers. Receive logic validates length, optionally verifies checksums, filters destination ports, and dispatches payloads to the correct application sink. Because UDP offers no retransmission, the module focuses on clean framing and explicit drop reporting instead of reliability state.

## Clocking, Reset, and Timing Assumptions

The block assumes lower layers provide valid IP payload boundaries and that higher layers can accept datagrams without per-byte flow control. Reset should flush partial packets and clear port-dispatch state so stale metadata cannot misroute a later datagram.

## Latency, Throughput, and Resource Considerations

UDP stacks can be highly streaming-friendly and usually sustain one beat per cycle once headers are handled. Resource use is modest compared with TCP because there is no connection state or retransmission bookkeeping.

## Verification Strategy

- Verify header generation and parsing, checksum behavior, and port dispatch on short and long datagrams.
- Inject malformed lengths, checksum failures, unsupported ports, and truncated packets.
- Check that application-side backpressure leads to documented drop or queue behavior rather than ambiguous stalling.

## Integration Notes and Dependencies

The UDP stack is typically the application-facing endpoint of the hardware network path, so its port-dispatch and buffer-ownership contracts should be easy for software and neighboring RTL to understand. Integrators should also define whether broadcast, multicast, and checksum-disabled traffic are allowed.

## Edge Cases, Failure Modes, and Design Risks

- Length fields and actual payload boundaries can diverge if parsers and generators use different byte-enable conventions.
- Applications sometimes assume UDP delivery is reliable enough and fail to handle drops reported by the hardware.
- Port filters that default open rather than explicit may expose unexpected traffic to application logic.

## Related Modules In This Domain

- arp_engine
- checksum_offload
- ethernet_mac

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the UDP Stack module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
