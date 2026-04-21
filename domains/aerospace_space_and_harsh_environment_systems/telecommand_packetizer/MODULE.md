# Telecommand Packetizer

## Overview

Telecommand Packetizer assembles or parses structured command payloads and associated metadata for mission command handling. It provides mission-oriented control-packet formatting at the boundary between command logic and communications transport.

## Domain Context

Telecommand packetization structures inbound or outbound command traffic in a mission-defined form before execution or transport. In this domain it is the command-facing counterpart to telemetry packaging and often sits close to authorization and safety logic.

## Problem Solved

Operational commands need a stable packet structure with clear source, sequence, and payload semantics. A dedicated packetizer keeps that structure explicit and consistent rather than allowing command formats to drift across subsystems.

## Typical Use Cases

- Packaging telecommands for simulation, uplink preparation, or internal routing.
- Parsing mission command payloads into structured fields for execution logic.
- Supporting deterministic command formatting in hardware-in-the-loop environments.
- Providing a reusable boundary between communications framing and command application logic.

## Interfaces and Signal-Level Behavior

- Inputs are command payload fields, control metadata, and packetization or parse control signals.
- Outputs provide structured command packets or parsed command fields plus validity status.
- Control interfaces configure packet layout, command class support, and sequence or acknowledgment metadata handling.
- Status signals may expose packet_done, parse_error, and command_format_invalid conditions.

## Parameters and Configuration Knobs

- Supported command classes or packet variants.
- Payload size and field-layout flexibility.
- Parser versus formatter versus dual-mode build support.
- Optional sequence or acknowledgment field support.

## Internal Architecture and Dataflow

The packetizer typically performs field assembly or extraction, metadata insertion, and packet boundary control around mission command structures. The key contract is whether the block only handles syntax or also performs semantic checks such as length, class validity, or protected field ranges.

## Clocking, Reset, and Timing Assumptions

The module assumes command sources or sinks share the same mission packet schema. Reset clears partial packet state. If command authorization or safety checks occur elsewhere, this boundary should be explicit so packet validity is not mistaken for command legitimacy.

## Latency, Throughput, and Resource Considerations

Area is modest and throughput requirements are usually low compared with telemetry or payload data. The important tradeoff is between flexible command schemas and keeping parsing or formatting deterministic and auditable.

## Verification Strategy

- Validate packet formatting or parsing against a mission schema reference.
- Stress malformed length, class, and sequence fields.
- Verify syntax-valid but semantically suspicious commands are surfaced appropriately if checks are included.
- Run end-to-end integration with CCSDS deframing or framing as applicable.

## Integration Notes and Dependencies

Telecommand Packetizer commonly works with CCSDS Deframer and Fault Management or scheduler logic that ultimately executes commands. It should align with mission ICDs and any higher-level authorization layers.

## Edge Cases, Failure Modes, and Design Risks

- Syntactic correctness must not be confused with operational safety or authorization.
- Schema drift between uplink tooling and hardware parsing can quietly misroute commands.
- Partial parsing support should be documented or operators may overestimate the protection the block provides.

## Related Modules In This Domain

- ccsds_deframer
- ccsds_framer
- fault_management_unit
- time_triggered_scheduler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Telecommand Packetizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
