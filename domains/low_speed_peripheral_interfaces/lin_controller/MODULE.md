# Lin Controller

## Overview

lin_controller implements the digital control and framing behavior required for LIN communication, including frame timing, identifier handling, checksum generation and checking, and host-facing data exchange. It is the serial control-bus engine for simple LIN networks.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

LIN is simpler than CAN, but framing, checksum policy, break detection, and master-slave timing still need to be correct and host-visible. lin_controller centralizes those details into one reusable block.

## Typical Use Cases

- Connect a simple actuator or sensor network over LIN.
- Provide master or slave LIN communication in automotive-style systems.
- Bridge software-controlled message slots onto a LIN bus.

## Interfaces and Signal-Level Behavior

- Bus-facing signals typically connect to a serial transceiver or line interface wrapper.
- Host-side controls include frame setup, data load, receive dequeue, and mode configuration.
- Status often reports break detect, sync received, checksum error, frame complete, and bus activity.

## Parameters and Configuration Knobs

- ROLE_MODE selects master, slave, or supported subset behavior.
- CHECKSUM_MODE defines classic or enhanced checksum handling if configurable.
- NUM_MESSAGE_SLOTS sizes host-visible staging resources.
- LOOPBACK_EN supports internal test.
- TIMEOUT_EN defines host-visible watchdog or frame-timeout support.

## Internal Architecture and Dataflow

A LIN controller usually contains break and sync detection, identifier and checksum handling, transmit and receive framing, and small host-visible staging buffers. The most important contract issue is how much of the frame schedule and slot timing is driven by software versus internal automation.

## Clocking, Reset, and Timing Assumptions

The module generally relies on an external physical interface. Reset should clear partial frame state and host buffers. Software must know whether the controller expects schedule-driven master operation, event-driven use, or a narrower subset.

## Latency, Throughput, and Resource Considerations

LIN bandwidth is low, so the value lies in correctness and software simplicity rather than peak throughput. Internal buffering and timeout logic determine usability under real traffic patterns.

## Verification Strategy

- Check transmit and receive of valid frames across the supported role modes.
- Exercise break detection, sync handling, and checksum errors.
- Verify timeout and incomplete-frame behavior.
- Compare host-visible status against a LIN protocol reference model.

## Integration Notes and Dependencies

lin_controller typically pairs with simple mailbox or register control and interrupt logic. It should make schedule ownership explicit so software knows whether it is driving slots or only reacting to them.

## Edge Cases, Failure Modes, and Design Risks

- Master versus slave role assumptions can diverge quickly if not documented.
- Checksum mode and frame-timing behavior must match the intended network.
- Timeout policy is easy to under-specify and becomes painful in system bring-up.

## Related Modules In This Domain

- uart_controller
- mailbox_block
- interrupt_controller
- pulse_capture

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Lin Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
