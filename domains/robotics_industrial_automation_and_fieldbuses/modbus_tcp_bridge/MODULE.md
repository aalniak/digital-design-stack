# Modbus TCP Bridge

## Overview

Modbus TCP Bridge maps local register or coil semantics onto Modbus TCP request-response behavior, optionally bridging to other internal or serial Modbus endpoints. It provides Ethernet-accessible Modbus integration for industrial devices.

## Domain Context

A Modbus TCP bridge connects Modbus-style application semantics to Ethernet-based plant networking. In automation systems it is commonly used to expose register-oriented device data over IP networks or to translate between serial-oriented and Ethernet-oriented Modbus deployments.

## Problem Solved

Moving from Modbus RTU to networked control adds connection handling, transaction identification, and Ethernet-facing service semantics. A dedicated bridge keeps those concerns organized and aligned with the same underlying register model used elsewhere.

## Typical Use Cases

- Exposing device registers to SCADA or PLC systems over Ethernet.
- Bridging an internal Modbus RTU map to a Modbus TCP interface.
- Providing maintenance or supervisory access across plant networks.
- Unifying serial and Ethernet Modbus-facing views of machine data.

## Interfaces and Signal-Level Behavior

- Inputs include local register data, TCP-side request events, and optional serial-side bridge transaction results.
- Outputs provide response payloads, exception codes, and request dispatch to the application register layer.
- Configuration tables define register maps, bridge policy, unit-ID handling, and access control.
- Diagnostic outputs may expose transaction errors, connection status, and bridge timeout conditions.

## Parameters and Configuration Knobs

- Register map size and transaction-buffer capacity.
- Supported function-code subset and bridge mode.
- TCP session or request concurrency assumptions.
- Timeout and retry policy for bridged serial back ends if used.

## Internal Architecture and Dataflow

The bridge usually includes request parsing, register dispatch or serial forwarding, response construction, and transaction bookkeeping. The contract should define whether it is a native TCP endpoint over local registers, a true RTU-to-TCP bridge, or both, because those modes have different latency and error semantics.

## Clocking, Reset, and Timing Assumptions

A lower TCP or Ethernet transport layer is assumed to deliver validated request payloads. Reset should clear in-flight transactions. If concurrent requests are limited or serialized intentionally, that should be explicit so plant integrators understand performance expectations.

## Latency, Throughput, and Resource Considerations

Resource cost is modest. Throughput depends on transport and any back-end bridging latency, but deterministic exception and timeout behavior matter more than raw request rate for most industrial uses. Clarity of register semantics remains critical.

## Verification Strategy

- Exercise valid read and write transactions, malformed requests, and exception paths.
- Check bridge behavior when the back-end register source or serial path stalls.
- Verify transaction-ID and response matching semantics under repeated requests.
- Compare exposed register behavior against the corresponding RTU or local register model.

## Integration Notes and Dependencies

Modbus TCP Bridge should align with Modbus RTU Controller or local register maps, Machine State Sequencer status, and system diagnostics so all operational views agree. It is often the easiest remote-service window into the device, which makes semantic consistency especially important.

## Edge Cases, Failure Modes, and Design Risks

- Inconsistent register behavior between RTU and TCP variants can create major commissioning confusion.
- If transaction concurrency assumptions are hidden, supervisory tools may overload the device unexpectedly.
- Bridge timeouts that are not surfaced clearly can look like incorrect machine data rather than communications delay.

## Related Modules In This Domain

- modbus_rtu_controller
- machine_state_sequencer
- profinet_endpoint
- canopen_helper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Modbus TCP Bridge module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
