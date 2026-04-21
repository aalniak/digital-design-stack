# Can Controller

## Overview

can_controller implements the digital protocol engine for classical CAN communication, including frame handling, filtering, arbitration participation, error tracking, and host-facing buffering. It is the reusable CAN control block above any physical transceiver.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

CAN seems simple at the message level, but arbitration, error confinement, retransmission, and acceptance filtering all need to behave consistently. can_controller centralizes those protocol rules behind one host-facing contract.

## Typical Use Cases

- Exchange control and telemetry messages on a CAN bus.
- Provide an embedded processor with mailbox-style CAN transmit and receive capability.
- Bridge industrial or automotive subsystems into a shared CAN network.

## Interfaces and Signal-Level Behavior

- Bus-facing outputs and inputs represent transmit and receive bit streams or a PHY-facing interface as defined by the implementation.
- Host-facing controls usually include message load, transmit request, receive dequeue, filters, and status reads.
- Status signals often include bus-off, error-passive, arbitration loss, receive available, and transmit complete.

## Parameters and Configuration Knobs

- ID_MODE selects standard or extended identifier support if configurable.
- NUM_FILTERS sets acceptance-filter resources.
- TX_MAILBOXES and RX_MAILBOXES size host-facing buffering.
- TIMING_CONFIG_MODE defines how bit timing parameters are exposed.
- LOOPBACK_EN enables self-test or internal loopback support.

## Internal Architecture and Dataflow

A CAN controller typically contains transmit and receive state machines, bit timing support, CRC and stuffing logic, acceptance filters, host-facing message buffering, and error counters. The reusable contract should make clear what buffering exists and which protocol details remain software-visible versus fully internal.

## Clocking, Reset, and Timing Assumptions

This module generally relies on an external transceiver for the analog bus. The host side must know whether transmit requests are queued, mailboxes are prioritized, and how received frame timestamps or status are reported. Reset should define how protocol error state and host buffers are cleared.

## Latency, Throughput, and Resource Considerations

Throughput is governed by CAN bus timing rather than internal clock speed, but internal buffering depth and filter structure determine how gracefully the controller handles back-to-back traffic. Hardware cost is shaped mainly by buffering and filtering resources.

## Verification Strategy

- Exercise transmit, receive, arbitration loss, and retransmission scenarios.
- Check acceptance filtering for all supported ID formats.
- Verify error counters, bus-off transitions, and recovery policy.
- Run randomized frame traffic with injected bit and CRC errors against a protocol reference model.

## Integration Notes and Dependencies

can_controller usually pairs with a transceiver-facing wrapper, host CSR logic, and mailbox or interrupt handling. It should define clearly whether software interacts with raw frames, mailboxes, or FIFOs.

## Edge Cases, Failure Modes, and Design Risks

- Error-state handling is a major interoperability risk if not modeled correctly.
- Acceptance-filter semantics that differ from software expectations can silently drop traffic.
- Mailbox ownership and retransmission policy must be explicit or host drivers become fragile.

## Related Modules In This Domain

- can_fd_controller
- mailbox_block
- interrupt_controller
- event_counter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Can Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
