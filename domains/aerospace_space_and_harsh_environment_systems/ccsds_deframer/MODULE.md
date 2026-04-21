# CCSDS Deframer

## Overview

CCSDS Deframer parses CCSDS-framed records into payload and metadata suitable for onboard consumers or validation logic. It provides the standards-oriented receive formatting stage for space communication systems.

## Domain Context

CCSDS deframing is the receive-side complement to standardized spacecraft telemetry or telecommand framing. In this domain it extracts payload and control metadata from received CCSDS structures while preserving enough status for fault and sequence management.

## Problem Solved

Mission data consumers should not need to understand every transport header and sequence rule. A dedicated deframer isolates those standards details and reports whether the received structure is valid before payload is trusted.

## Typical Use Cases

- Receiving and unpacking framed telemetry or telecommand data.
- Checking sequence and structural validity of CCSDS traffic.
- Supplying onboard software or hardware with clean payload plus parsed metadata.
- Supporting hardware-in-the-loop tests of spacecraft communications flows.

## Interfaces and Signal-Level Behavior

- Inputs are framed CCSDS records with valid signaling from a lower transport layer.
- Outputs provide payload, parsed header fields, and frame-valid or error status.
- Control interfaces configure supported profile, error policy, and how sequence or metadata checks are reported.
- Status signals may expose format_error, sequence_warning, and payload_valid indications.

## Parameters and Configuration Knobs

- Supported CCSDS profile subset.
- Maximum frame length and payload width.
- Optional frame-check validation support.
- Metadata extraction detail level.

## Internal Architecture and Dataflow

The deframer typically contains header parsing, length tracking, payload extraction, and status generation around sequence or frame-check interpretation. The architectural contract should specify whether the block merely parses structure or also enforces sequence continuity and other mission-level checks.

## Clocking, Reset, and Timing Assumptions

The module assumes a lower link layer delivers ordered and complete frames according to the selected transport. Reset clears partial parse state and sequence history according to policy. If some headers are mission-specific, the boundary between generic CCSDS handling and mission payload interpretation should be explicit.

## Latency, Throughput, and Resource Considerations

The deframer is modest in area and usually not a throughput bottleneck relative to the transport. The important performance question is how early it can reject malformed data and how much buffering is needed before payload release.

## Verification Strategy

- Compare parsed outputs against a CCSDS reference implementation and golden frames.
- Stress malformed headers, truncated frames, and sequence discontinuities.
- Verify payload release policy under frame errors.
- Run end-to-end tests with the paired framer and mission packet-processing tools.

## Integration Notes and Dependencies

CCSDS Deframer often feeds Telecommand Packetizer or mission control logic and works with SpaceWire or other transport links. It should align with fault-management policy on whether structural errors are logged, retried, or escalated.

## Edge Cases, Failure Modes, and Design Risks

- Payload release before full structural validation can let bad commands reach downstream logic.
- Sequence interpretation is mission sensitive and should not be implied if not implemented.
- Partial support for the standard must be documented or operators will overestimate interoperability.

## Related Modules In This Domain

- ccsds_framer
- telecommand_packetizer
- spacewire_link_block
- fault_management_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CCSDS Deframer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
