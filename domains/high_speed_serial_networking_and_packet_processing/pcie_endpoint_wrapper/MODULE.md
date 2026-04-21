# PCIe Endpoint Wrapper

## Overview

The PCIe endpoint wrapper presents a stable, design-friendly interface around a hard or soft PCIe endpoint implementation. It normalizes configuration, reset, transport streams, and link-status behavior so higher-level DMA or accelerator logic is not tightly coupled to one vendor-specific PCIe IP boundary.

## Domain Context

High-speed serial, networking, and packet-processing modules sit on the throughput-critical edge of the system. In this domain the docs focus on framing rules, packet boundaries, metadata propagation, error detection, flow control, and how line-side timing behavior maps into wider internal packet fabrics.

## Problem Solved

Raw PCIe hard IP interfaces are powerful but often device-specific and not pleasant to integrate directly. A wrapper is needed to hide lane-training detail, transport stream formatting quirks, configuration-space plumbing, and clock-domain boundaries behind a cleaner contract. This module serves as that adapter layer.

## Typical Use Cases

- Connecting DMA engines and control registers to a vendor hard PCIe block through a portable shell.
- Abstracting generation-specific PCIe transport interfaces so the rest of the repo remains reusable.
- Centralizing link status, function reset, MSI or MSI-X, and configuration reporting for a device design.

## Interfaces and Signal-Level Behavior

- User side commonly exposes request and completion streams, configuration registers, interrupt triggers, and link-status outputs.
- Core side maps directly to hard IP transport interfaces, configuration ports, and physical reset or reference-clock signals.
- Support logic may include bridges for BAR decoding, CSR access, or descriptor-doorbell paths.

## Parameters and Configuration Knobs

- Lane width, speed generation, number of BARs, interrupt mode support, and configuration-space options.
- Vendor-family adaptation mode and optional clock-domain bridge placement.
- Payload-size negotiation exposure and whether the wrapper contains address translation helpers or leaves them external.

## Internal Architecture and Dataflow

A good wrapper partitions vendor-specific transport adaptation from design-specific packet consumers. It often includes link-state monitors, reset sequencing, BAR decode helpers, MSI generation support, and stream adapters that present normalized request and completion channels to user logic. Some implementations also separate control-plane CSRs from high-throughput data paths so slower configuration traffic cannot perturb DMA timing.

## Clocking, Reset, and Timing Assumptions

The underlying PCIe core owns physical-layer bring-up and compliance behaviors, while this wrapper owns correct adaptation into the internal fabric. Reset sequencing is subtle because PCIe function reset, hot reset, and user resets can interact; the wrapper must document what each reset source clears.

## Latency, Throughput, and Resource Considerations

The wrapper itself should add minimal latency, but buffering and adaptation may still cost a few cycles. Area is modest compared with a full DMA engine, though extra portability layers and CDC bridges can increase footprint.

## Verification Strategy

- Verify link-up reporting, reset propagation, BAR decoding, and interrupt signaling around the wrapped endpoint core.
- Check that transport streams preserve ordering and sideband metadata across any adaptation layers.
- Exercise hot reset and function reset sequences to confirm downstream logic returns to a clean state.

## Integration Notes and Dependencies

This wrapper is the contractual seam between vendor IP and the reusable repository. Integration should spell out which signals are considered stable API, how software-visible configuration space is populated, and which features remain specific to a given target FPGA family.

## Edge Cases, Failure Modes, and Design Risks

- Leaking too much vendor-specific detail through the wrapper undermines its portability value.
- Reset mismatches between wrapped core and user logic can leave transaction streams half alive after link events.
- If BAR decode or configuration routing is ambiguous, software may interact with the wrong internal block.

## Related Modules In This Domain

- pcie_dma_engine
- axi_lite_slave
- debug_bridge

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PCIe Endpoint Wrapper module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
