# Bitstream Loader

## Overview

Bitstream Loader fetches, buffers, and delivers configuration bitstreams to the appropriate FPGA configuration interface while reporting status and integrity-relevant errors. It provides the controlled path for loading full or partial FPGA configuration images.

## Domain Context

A bitstream loader is the platform-control block that delivers FPGA configuration or reconfiguration images into the device or a reconfigurable region. In this domain it is the data-moving and policy boundary between stored configuration images and the configuration interface that consumes them.

## Problem Solved

Configuration images are large, timing sensitive, and often tied to strict sequencing or integrity expectations. A dedicated loader centralizes image fetch, pacing, and failure reporting so reconfiguration logic does not need to reinvent these concerns.

## Typical Use Cases

- Loading a full FPGA image from local storage or memory-mapped flash.
- Feeding partial reconfiguration data into a region-specific control flow.
- Supporting field updates or remote reconfiguration workflows.
- Providing deterministic hardware-side bitstream transfer for platform management.

## Interfaces and Signal-Level Behavior

- Inputs include image source data or source descriptors, load-start commands, and target-interface readiness from a configuration port.
- Outputs provide streamed bitstream words, load progress, and success or failure status.
- Control interfaces configure source selection, transfer pacing, and optional integrity-check or abort policy.
- Status signals may expose load_active, source_underflow, target_stall, and bitstream_error indications.

## Parameters and Configuration Knobs

- Supported source width and target interface width.
- Maximum bitstream size or descriptor range.
- Full-image versus partial-image load mode support.
- Optional checksum or metadata validation support.

## Internal Architecture and Dataflow

The loader generally contains source-side fetching, buffering, flow control toward the configuration interface, and progress or error reporting. The key contract is whether it merely transports bitstream bytes or also validates format metadata and target compatibility before transfer, because reconfiguration safety depends on that boundary.

## Clocking, Reset, and Timing Assumptions

The block assumes the source image has already been authenticated or otherwise approved if security is a concern, unless such validation is explicitly part of this module. Reset should abort active transfers and return the target interface to an idle-safe state. If several bitstream sources are supported, source handoff and descriptor validity rules should be explicit.

## Latency, Throughput, and Resource Considerations

Throughput matters because configuration latency can dominate startup or reconfiguration time. The main tradeoff is between a simple streaming path and richer buffering or validation support that may improve robustness but add latency and complexity.

## Verification Strategy

- Verify bitstream transfer integrity and pacing against the target configuration interface requirements.
- Stress underflow, abort, and target backpressure conditions.
- Check descriptor parsing and size-bound enforcement.
- Run end-to-end configuration tests with representative full and partial images.

## Integration Notes and Dependencies

Bitstream Loader commonly feeds ICAP or PCAP control logic and works alongside Partial Reconfiguration Manager. It should align with storage, update, and configuration-security policy so image origin and target-region assumptions remain coherent.

## Edge Cases, Failure Modes, and Design Risks

- A transport-only loader may be misused as though it also validated image correctness or destination compatibility.
- Abort and retry semantics around partially delivered images must be clear to avoid leaving the device in an undefined state.
- Source underflow handling is especially important during remote or slow-storage loads.

## Related Modules In This Domain

- icap_pcap_controller
- partial_reconfiguration_manager
- startup_sequencer
- mmcm_pll_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bitstream Loader module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
