# CANopen Helper

## Overview

CANopen Helper implements the application-facing conveniences around CANopen object access, state handling, and profile integration. It helps a device participate in CANopen control flows without every subsystem re-implementing the protocol glue.

## Domain Context

CANopen helper logic provides the object-model and message-handling scaffolding needed when a machine or drive exposes control and diagnostics over CANopen. In industrial automation this sits between the application state machine and the CAN fieldbus transport.

## Problem Solved

CANopen is more than raw CAN frames; it includes object dictionaries, device states, PDO behavior, and service access patterns. A helper block keeps those recurring integration tasks standardized and easier to reuse across industrial nodes.

## Typical Use Cases

- Exposing axis status and parameters through a CANopen object dictionary.
- Supporting CANopen state transitions in a drive or actuator node.
- Mapping process data objects to machine-control signals.
- Providing a consistent integration layer for service and diagnostic access over CAN.

## Interfaces and Signal-Level Behavior

- Inputs include application data items, state requests, and frame-level events from a lower CAN/CANopen transport layer.
- Outputs provide object values, PDO mappings, state indications, and request dispatch to local application logic.
- Control registers or configuration tables define object entries, profile support, and mapping rules.
- Diagnostic outputs may expose state-transition errors, access faults, and mapping conflicts.

## Parameters and Configuration Knobs

- Object count and indexing width.
- PDO mapping capacity and update policy.
- Supported CANopen device-profile features.
- Access-control or callback depth for application integration.

## Internal Architecture and Dataflow

The helper typically contains object-dictionary access logic, state-machine support, and application-facing PDO or SDO dispatch paths. The key contract is the boundary between generic CANopen behavior and product-specific object semantics, because reuse depends on keeping that split clean.

## Clocking, Reset, and Timing Assumptions

A lower-layer CAN and transport engine is assumed to provide validated frame events. Reset should return the device-helper state to a known startup mode. If some profile features are only partially implemented, the documentation should make those limits explicit.

## Latency, Throughput, and Resource Considerations

Logic cost is moderate and mostly table-driven. Throughput is generally bounded by CAN traffic rates, so clarity of object semantics matters more than extreme speed. Deterministic state handling remains important for interoperability.

## Verification Strategy

- Exercise object access, PDO mapping, and state transitions against a CANopen reference or conformance plan.
- Stress invalid object requests and mapping conflicts.
- Verify startup and reset behavior across expected node-control sequences.
- Check that application-facing callbacks and data mirrors remain consistent under traffic bursts.

## Integration Notes and Dependencies

CANopen Helper connects fieldbus application semantics to Machine State Sequencer, Servo Loop Helper, and device diagnostics. It should align with the specific device profile the machine intends to present so PLC-side assumptions remain valid.

## Edge Cases, Failure Modes, and Design Risks

- Implementing only part of the expected object semantics can create subtle interoperability failures.
- If device state and machine state are not mapped carefully, PLC control may become confusing or unsafe.
- A helper that blurs transport and application responsibilities becomes hard to maintain across products.

## Related Modules In This Domain

- machine_state_sequencer
- servo_loop_helper
- modbus_rtu_controller
- modbus_tcp_bridge

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CANopen Helper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
