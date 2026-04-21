# ICAP/PCAP Controller

## Overview

ICAP/PCAP Controller sequences commands and data transfer over internal or processor-accessible FPGA configuration ports and exposes configuration progress and fault status. It provides the hardware-facing control layer for device configuration interfaces.

## Domain Context

ICAP and PCAP controllers are the device-side interfaces that drive FPGA configuration and reconfiguration transactions through internal or processor-accessed configuration ports. In this domain they are the low-level command and status layer beneath higher-level bitstream management.

## Problem Solved

Configuration ports have strict protocol expectations, ordering rules, and error semantics that should not be handled ad hoc by every reconfiguration feature. A dedicated controller keeps those details localized and testable.

## Typical Use Cases

- Driving full or partial configuration through an internal configuration access port.
- Providing a software-visible control path to the FPGA configuration engine.
- Coordinating bitstream transfer and completion status during dynamic reconfiguration.
- Abstracting family-specific configuration port details behind a local interface.

## Interfaces and Signal-Level Behavior

- Inputs include configuration command requests, bitstream data from a loader, reset or abort control, and optional software register accesses.
- Outputs provide target-port control signals, configuration status, and completion or error reporting.
- Control interfaces configure operating mode, target region or configuration context, and retry or abort policy.
- Status signals may expose config_busy, crc_error, command_error, and transfer_done indications.

## Parameters and Configuration Knobs

- Supported configuration port type, such as ICAP or PCAP.
- Data width and endianness or word-order handling.
- Full versus partial configuration support.
- Optional software register or DMA-facing interface style.

## Internal Architecture and Dataflow

The controller usually contains configuration command sequencing, data-port adaptation, status monitoring, and abort or reset handling. The key contract is whether this block owns only port-level protocol or also policy around which images and regions may be configured, because those responsibilities are often confused.

## Clocking, Reset, and Timing Assumptions

The module assumes incoming bitstream data is delivered in the correct format for the target port and that higher layers manage any required image approval unless stated otherwise. Reset should leave the configuration port idle and recoverable. If the target family imposes strict port timing or command ordering, those assumptions should be surfaced clearly.

## Latency, Throughput, and Resource Considerations

Configuration-port bandwidth often sets the lower bound on reconfiguration time. The controller tradeoff is between thin protocol translation and richer visibility, buffering, or command management. Robust status reporting is often more important than squeezing out the last small percentage of bandwidth.

## Verification Strategy

- Verify command sequencing and data transfer against the targeted configuration-port specification.
- Stress abort, reset, and malformed command or data scenarios.
- Check error reporting and recovery after a failed configuration attempt.
- Run integrated reconfiguration tests with Bitstream Loader and Partial Reconfiguration Manager.

## Integration Notes and Dependencies

ICAP/PCAP Controller usually sits beneath Bitstream Loader and Partial Reconfiguration Manager and may expose status to software control logic. It should align with device-family documentation and any security policy that constrains when configuration ports may be used.

## Edge Cases, Failure Modes, and Design Risks

- Port-level correctness is necessary but not sufficient if higher layers assume policy enforcement that is not actually present here.
- Configuration-port error recovery is often under-tested until hardware integration.
- Family-specific port behavior can make a supposedly generic controller brittle across devices.

## Related Modules In This Domain

- bitstream_loader
- partial_reconfiguration_manager
- startup_sequencer
- vendor_ram_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ICAP/PCAP Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
