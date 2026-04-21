# I2c Master Slave

## Overview

i2c_master_slave implements I2C protocol behavior in master mode, slave mode, or both, including start-stop sequencing, acknowledgment, address match, and host-facing data movement. It is the general-purpose serial control-bus engine of the low-speed peripheral layer.

## Domain Context

In the Low-Speed Peripheral Interfaces domain, modules are judged by how clearly they define bus timing, framing, software-visible control, error recovery, and the boundary between digital logic and the outside world. These blocks often look simple until edge cases like retries, timing margins, or line ownership appear.

## Problem Solved

I2C is electrically simple but protocol-rich enough that start conditions, arbitration, stretching, addressing, and acknowledgment handling can quickly become inconsistent across implementations. i2c_master_slave centralizes those rules.

## Typical Use Cases

- Control sensors, EEPROMs, power chips, or small peripherals over I2C.
- Expose a device-side I2C register or mailbox endpoint.
- Support systems that need either bus initiation, device response, or both.

## Interfaces and Signal-Level Behavior

- Bus-facing signals are SDA and SCL with direction control as required by the implementation.
- Host-facing controls usually include transfer request, address, data payload, mode selection, and status.
- Status often includes busy, arbitration lost, nack received, slave-address match, and transfer complete.

## Parameters and Configuration Knobs

- ADDRESS_MODE selects 7-bit or 10-bit support.
- MASTER_EN and SLAVE_EN scope supported roles.
- CLOCK_STRETCH_EN declares stretching support.
- FIFO_DEPTH sizes host-facing buffering if present.
- FILTER_EN adds digital glitch filtering on bus inputs.

## Internal Architecture and Dataflow

A combined master-slave block usually contains a bit-level timing engine, start-stop detection, byte framing, ACK handling, and host-side buffering or register interfaces. The key documentation points are which optional I2C behaviors are supported and how role switching is controlled.

## Clocking, Reset, and Timing Assumptions

Open-drain electrical behavior is typically handled through pad control outside or alongside the core. Software must know whether the block supports repeated starts, clock stretching, arbitration loss recovery, and multi-byte queued transactions.

## Latency, Throughput, and Resource Considerations

I2C bandwidth is low, so internal timing margin is usually ample; however, host buffering and bus-recovery behavior determine usability under real workloads. Feature-rich combined mode costs more area than a single-role core.

## Verification Strategy

- Exercise master reads, writes, repeated starts, and stop conditions.
- Verify slave address matching and data response paths.
- Check nack, arbitration loss, and stretch-related behavior.
- Use protocol-aware bus models with injected timing disturbances or illegal sequences.

## Integration Notes and Dependencies

i2c_master_slave usually pairs with simple CSR control and sometimes interrupt or DMA hooks for queued transfers. It should clearly separate host-side convenience features from strict protocol capability.

## Edge Cases, Failure Modes, and Design Risks

- Multi-role support can make behavior ambiguous if mode ownership is not explicit.
- Bus-recovery and nack handling are easy to under-specify.
- Ignoring electrical realities such as open-drain ownership or glitch filtering can undermine a logically correct core.

## Related Modules In This Domain

- i3c_basic_controller
- gpio_bank
- interrupt_controller
- pulse_capture

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the I2c Master Slave module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
