# Can Fd Controller

## Overview

can_fd_controller extends classical CAN control with CAN FD features such as larger payloads and data-phase timing changes while preserving host-facing visibility into arbitration, filtering, and error state. It is the higher-capability CAN engine for modern systems.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

CAN FD adds flexibility and bandwidth, but it also adds more corner cases around payload handling, bit-rate switching, and error treatment. can_fd_controller makes those added semantics explicit.

## Typical Use Cases

- Exchange larger payload messages on CAN FD networks.
- Support mixed classical CAN and CAN FD operation in one subsystem.
- Provide a host-visible mailbox or queue interface to a CAN FD bus.

## Interfaces and Signal-Level Behavior

- Bus-facing signals connect to a suitable CAN FD transceiver or bit-level wrapper.
- Host-facing controls include frame load, rate or mode configuration, filter programming, and status.
- Status commonly includes FD enable, bit-rate-switch activity, error state, receive availability, and transmit completion.

## Parameters and Configuration Knobs

- FD_PAYLOAD_MAX sets maximum payload support.
- BRS_SUPPORT_EN enables bit-rate switching.
- NUM_FILTERS and mailbox counts size host-facing resources.
- CLASSIC_COMPAT_MODE defines mixed CAN and CAN FD behavior.
- LOOPBACK_EN enables test modes.

## Internal Architecture and Dataflow

In addition to the classical CAN building blocks, a CAN FD controller must handle larger payload framing, data-phase timing differences, and corresponding status reporting. The key contract questions are how host software specifies FD frames and how mixed-network operation is surfaced.

## Clocking, Reset, and Timing Assumptions

An appropriate physical-layer interface exists beneath the controller. Software must know which mailboxes or frame descriptors can carry FD features and how the controller reports unsupported or downgraded operation.

## Latency, Throughput, and Resource Considerations

CAN FD increases practical payload throughput, so receive buffering and host-drain behavior matter more than in classical CAN. Internal clocking and FIFO depth should be sized for worst-case back-to-back FD frames.

## Verification Strategy

- Exercise classical and FD frames, with and without bit-rate switching.
- Verify payload-length handling across the full supported range.
- Inject protocol and CRC errors in both arbitration and data phases.
- Check host-facing status and filtering against a CAN FD reference model.

## Integration Notes and Dependencies

can_fd_controller often shares software abstractions with classical CAN but needs clearer configuration and capability reporting. It should define whether it can coexist on the same driver model as a simpler CAN controller.

## Edge Cases, Failure Modes, and Design Risks

- Mixed classical and FD behavior can create subtle interoperability bugs.
- Host-visible payload-length semantics must be exact or buffers will be misused.
- Bit-rate-switch and error-state reporting need to align with the software stack precisely.

## Related Modules In This Domain

- can_controller
- mailbox_block
- interrupt_controller
- event_counter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Can Fd Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
