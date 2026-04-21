# ARINC429 Helper

## Overview

ARINC429 Helper assists with formatting, parsing, and routing ARINC 429 words and label-centric metadata at the digital interface boundary. It provides a reusable avionics bus utility layer for ARINC-oriented subsystems.

## Domain Context

ARINC 429 is a unidirectional word-oriented avionics bus standard used heavily in aircraft systems. In this domain a helper block provides the label, word, and timing handling needed to integrate ARINC traffic into digital logic cleanly.

## Problem Solved

ARINC words carry structured label and status semantics that are inconvenient to reconstruct repeatedly in application logic. A dedicated helper centralizes those conventions and simplifies integration with other control and telemetry logic.

## Typical Use Cases

- Formatting outbound ARINC words from internal subsystem values.
- Parsing inbound ARINC words into label and payload fields.
- Supporting avionics integration and validation environments.
- Providing a reusable bridge between legacy aircraft buses and modern digital logic.

## Interfaces and Signal-Level Behavior

- Inputs include received ARINC words or internal payload fields plus label and scheduling metadata.
- Outputs provide parsed label fields, transmitted word streams, and validity or parity status.
- Control interfaces configure supported labels, direction, and filtering or routing rules.
- Status signals may expose parity_error, unsupported_label, and word_valid indications.

## Parameters and Configuration Knobs

- Supported label count and label width.
- Transmit, receive, or bidirectional helper mode.
- Buffer depth and optional scheduling or rate-limiting support.
- Label-filter or rewrite-table capacity.

## Internal Architecture and Dataflow

The helper usually contains label extraction or insertion, parity handling, routing or filtering, and local buffering around word boundaries. The key contract is whether it assumes an external serializer or deserializer for the physical signaling or includes only digital word-level handling.

## Clocking, Reset, and Timing Assumptions

The block assumes a lower-level physical interface presents or consumes correctly timed ARINC words. Reset clears filters and pending word buffers. If label filtering or routing tables are programmable, the activation boundary should be explicit to avoid inconsistent behavior mid-stream.

## Latency, Throughput, and Resource Considerations

ARINC throughput is low, so clarity of semantics dominates over speed. The main tradeoff is between flexible label routing and minimal resource usage in systems that only need a fixed subset of labels.

## Verification Strategy

- Validate parsing and formatting against known ARINC word examples and parity rules.
- Stress unsupported labels, parity errors, and filtering behavior.
- Check transmit and receive timing assumptions at the word boundary.
- Run integration tests with representative avionics data flows or simulators.

## Integration Notes and Dependencies

ARINC429 Helper often connects mission control or telemetry logic to aircraft bus adapters and should align with the system?s label map and ICDs. It is best treated as word-level helper logic, not a full physical-layer implementation unless explicitly stated.

## Edge Cases, Failure Modes, and Design Risks

- Label-map mistakes can make values appear on the wrong avionics channel without obvious digital failure.
- Parity and status-bit handling must be clear or integration tooling will disagree with hardware interpretation.
- Overstating the helper as a full ARINC endpoint can mislead system integrators about physical-layer responsibilities.

## Related Modules In This Domain

- telemetry_packetizer
- telecommand_packetizer
- health_monitor_block
- fault_management_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ARINC429 Helper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
