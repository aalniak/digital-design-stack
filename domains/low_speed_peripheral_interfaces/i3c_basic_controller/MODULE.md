# I3c Basic Controller

## Overview

i3c_basic_controller provides a pragmatic subset of I3C controller behavior suitable for systems that want modern serial-control improvements over I2C without implementing the full feature space. It is the scoped I3C boundary block for reusable designs.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

I3C introduces richer bus behavior and dynamic capabilities, but many projects only need a subset. Without a clearly scoped controller, teams either overbuild or accidentally rely on unsupported behavior. i3c_basic_controller makes the supported subset explicit.

## Typical Use Cases

- Control modern peripherals on an I3C-capable shared bus.
- Provide a migration path from I2C-style control to a richer serial bus.
- Support systems that need a limited but well-documented I3C controller feature set.

## Interfaces and Signal-Level Behavior

- Bus-facing signals include the shared serial lines and any mode-related drive control needed by the implementation.
- Host-facing controls include command issue, addressing, transfer setup, and status readback.
- Status may expose bus busy, transfer complete, nack-like conditions, arbitration or protocol faults, and capability limitations.

## Parameters and Configuration Knobs

- SUPPORTED_FEATURE_SET documents which I3C capabilities are implemented.
- DYNAMIC_ADDRESS_EN indicates whether dynamic addressing flows are supported.
- I2C_COMPAT_EN defines coexistence behavior with legacy I2C devices.
- FIFO_DEPTH sizes host buffering.
- TIMING_MODE selects the supported speed and turnaround modes.

## Internal Architecture and Dataflow

A basic controller typically implements a constrained command and transfer engine rather than the entire standard feature set. The architecture should make feature boundaries obvious so unsupported bus operations are rejected cleanly rather than partially imitated.

## Clocking, Reset, and Timing Assumptions

This module should be judged as a scoped implementation, not a promise of full-standard coverage. Software must know the exact supported feature subset, especially around address assignment, in-band interrupts, and mixed-bus behavior if those are omitted or reduced.

## Latency, Throughput, and Resource Considerations

I3C capability can improve bus efficiency, but a basic controller usually prioritizes manageable feature scope over maximum performance. Buffering and command sequencing quality matter more than peak bus mode claims.

## Verification Strategy

- Exercise every supported command or transfer type explicitly.
- Verify clean rejection or fault reporting for unsupported features.
- Check coexistence or compatibility behavior if legacy modes are supported.
- Use a protocol-aware bus model that matches the declared subset rather than the entire standard.

## Integration Notes and Dependencies

i3c_basic_controller should sit alongside software and hardware abstractions that understand it is a scoped feature implementation. It is most successful when the supported subset is narrow, honest, and well tested.

## Edge Cases, Failure Modes, and Design Risks

- The biggest hazard is accidental feature creep beyond what the implementation truly supports.
- Mixed I2C or I3C assumptions can break integration if compatibility behavior is vague.
- Software stacks may assume standard coverage unless the limitations are impossible to miss.

## Related Modules In This Domain

- i2c_master_slave
- gpio_bank
- interrupt_controller
- dma_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the I3c Basic Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
