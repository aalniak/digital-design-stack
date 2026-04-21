# Mdio Controller

## Overview

mdio_controller manages MDIO transactions used to read and write management registers in Ethernet PHYs and similar devices. It is the low-bandwidth control-plane bridge into external management interfaces.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

MDIO traffic is slow but timing-sensitive and often embedded in larger networking systems. mdio_controller prevents every MAC or management block from inventing its own clause-specific control logic and software interface.

## Typical Use Cases

- Configure and monitor Ethernet PHY registers.
- Expose management transactions to software through a local control plane.
- Poll external device status over a simple serial management bus.

## Interfaces and Signal-Level Behavior

- Bus-facing signals usually include MDC and MDIO with direction control.
- Host-facing inputs include target address, register address, read or write request, and write data.
- Outputs include read data, busy, done, and timeout or protocol error status.

## Parameters and Configuration Knobs

- CLAUSE_MODE selects supported MDIO clause behavior.
- CLOCK_DIVIDER sets MDC generation relative to the system clock.
- TIMEOUT_EN enables stalled-bus detection.
- PREFETCH_EN or POLL_EN may add repeated-read support if implemented.
- TURNAROUND_POLICY defines handling around read and write turnaround cycles.

## Internal Architecture and Dataflow

The controller is typically a compact serial state machine that emits management frames, handles turnaround timing, and collects returned data. The key contract details are supported clause subset, timing configuration, and host-side busy or completion semantics.

## Clocking, Reset, and Timing Assumptions

The target devices must match the supported MDIO clause behavior. Reset should leave the line idle and clear any partially issued transaction. If polling support exists, it should be separated clearly from one-shot transaction behavior.

## Latency, Throughput, and Resource Considerations

MDIO is inherently low throughput, so simplicity and correctness dominate. Hardware cost is minimal, but mis-handled serial timing or turnaround behavior can still break interoperability completely.

## Verification Strategy

- Check read and write transactions for the supported clause modes.
- Verify MDC generation and turnaround timing.
- Exercise timeout and absent-device behavior.
- Compare captured data and completion timing against an MDIO reference model.

## Integration Notes and Dependencies

mdio_controller usually sits beside a MAC or network-management software path. Its interface should make it obvious whether software is expected to poll one transaction at a time or can queue several.

## Edge Cases, Failure Modes, and Design Risks

- Clause-specific assumptions are the biggest interoperability hazard.
- Turnaround timing mistakes can pass simulation and fail on hardware.
- A stuck bus needs a documented timeout or recovery path or software can hang indefinitely.

## Related Modules In This Domain

- ethernet_mac
- gpio_bank
- interrupt_controller
- timer_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Mdio Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
