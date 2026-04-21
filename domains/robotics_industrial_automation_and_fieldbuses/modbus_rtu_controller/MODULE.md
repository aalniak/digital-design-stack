# Modbus RTU Controller

## Overview

Modbus RTU Controller implements the device-side or controller-side handling needed for Modbus RTU transactions over a serial interface, exposing registers and coils tied to local machine behavior. It is the serial protocol adapter for industrial control data.

## Domain Context

A Modbus RTU controller provides serial-fieldbus access to machine data and commands in many industrial environments, especially where simple PLCs, HMIs, or legacy systems are present. It is often the lowest-friction integration path for configuration and status exchange.

## Problem Solved

Raw UART transport does not provide the register semantics, timing, or exception behavior expected by Modbus tools. A dedicated RTU controller makes those conventions explicit and keeps register mapping consistent across products.

## Typical Use Cases

- Exposing configuration and status registers to a PLC or HMI over RS-485.
- Polling distributed devices in a simple industrial control network.
- Providing a low-complexity commissioning and diagnostics interface.
- Bridging legacy serial control infrastructure to newer embedded logic.

## Interfaces and Signal-Level Behavior

- Inputs include local register values, command requests, UART-frame events, and link-status information.
- Outputs provide register read or write dispatch, response generation, and exception or timeout status.
- Configuration tables define register maps, access permissions, and unit IDs.
- Diagnostic outputs may expose CRC failures, framing errors, illegal access attempts, and timeout counters.

## Parameters and Configuration Knobs

- Register map size and address width.
- Supported function-code subset and exception handling policy.
- UART timing assumptions such as inter-frame gap handling.
- Master, slave, or dual-role operating mode.

## Internal Architecture and Dataflow

The controller usually contains RTU frame parsing, register-access dispatch, response formatting, and exception handling. The contract should separate transport parsing from application register semantics so the same engine can back different industrial devices cleanly.

## Clocking, Reset, and Timing Assumptions

A lower UART or serial interface is assumed to provide bytes and framing status. Reset should clear outstanding transaction state and return the register protocol engine to idle. If the implementation is slave-only or omits some function codes, that should be stated directly.

## Latency, Throughput, and Resource Considerations

Resource cost is low. Throughput is limited by serial bandwidth, so predictability and clear exception behavior matter more than speed. Reliable framing and timeout handling are the most important operational characteristics.

## Verification Strategy

- Exercise valid reads and writes, illegal function codes, CRC failures, and timeout scenarios.
- Verify register access semantics and side effects against the documented map.
- Stress back-to-back transactions and frame-gap edge cases.
- Check controller or slave role behavior if both are supported.

## Integration Notes and Dependencies

Modbus RTU Controller links local machine data, machine state, and diagnostics to serial industrial tools. It should align its register map with the same underlying semantics exposed through other interfaces so operators do not see contradictory representations.

## Edge Cases, Failure Modes, and Design Risks

- A register-map mismatch can make commissioning tools change the wrong machine behavior.
- Poor frame-gap handling can cause intermittent communication failures that are hard to reproduce.
- If exceptions are underspecified, integrators may assume operations succeeded when they did not.

## Related Modules In This Domain

- modbus_tcp_bridge
- machine_state_sequencer
- canopen_helper
- profinet_endpoint

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Modbus RTU Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
