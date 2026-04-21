# AHCI Lite Frontend

## Overview

The AHCI Lite frontend exposes a reduced AHCI-style programming model for SATA-attached storage while avoiding the full complexity of a desktop-class host controller. It is useful when software expects familiar command-list and status semantics but the target design only needs a narrow feature subset.

## Domain Context

Storage and external memory modules bridge the gap between bursty software-visible I/O semantics and the strict timing behavior of memories, flash devices, and block-oriented transports. In this domain the key concerns are command ordering, data integrity, sustained bandwidth, recovery from long-latency operations, and clear ownership of queue and buffer state.

## Problem Solved

SATA link logic alone does not provide a software-friendly storage interface. Host software often wants descriptors, command issue bits, completion status, and error reporting shaped like AHCI. This module maps that software model onto a simpler hardware pipeline so storage commands can be launched and tracked without implementing every optional AHCI capability.

## Typical Use Cases

- Presenting a recognizable storage-control model to embedded firmware using SATA media.
- Driving a single-device or small-port-count SATA subsystem from a lightweight SoC.
- Supporting lab or appliance designs that want queued command control without desktop-class complexity.

## Interfaces and Signal-Level Behavior

- Software side usually exposes registers for command issue, command list base, status, interrupt causes, and error bits.
- Backend side exchanges command descriptors and data movement requests with a SATA link or storage DMA path.
- Optional buffer interfaces connect to local RAM that holds command tables, PRDT-style entries, or response structures.

## Parameters and Configuration Knobs

- Number of ports, command-slot depth, supported ATA command subset, and interrupt behavior.
- Descriptor memory interface width, DMA coupling style, and error-report detail.
- Feature gating for Native Command Queuing, power-management hooks, or port-multiplier exclusion.

## Internal Architecture and Dataflow

The frontend usually contains a CSR-visible control plane, a command fetch and decode path, slot tracking, and completion reporting logic that cooperates with the SATA data and transport layers. In a lite implementation many optional AHCI capabilities are removed, but the command lifecycle remains explicit: software posts work, hardware translates that into backend transactions, and status is retired in a way firmware can poll or interrupt on.

## Clocking, Reset, and Timing Assumptions

The document should state clearly which AHCI registers and command features are implemented versus stubbed. Reset and fatal-error handling must bring command-slot state back to a software-visible baseline so firmware never mistakes a stale in-flight slot for a newly issued one.

## Latency, Throughput, and Resource Considerations

Control-path overhead is small relative to media latency, but queue depth and descriptor-fetch efficiency still affect throughput on sequential workloads. Area is driven mostly by slot tracking, descriptor buffering, and software-visible status plumbing.

## Verification Strategy

- Verify command issue, completion, interrupt reporting, and software-visible status transitions.
- Exercise aborts, backend timeouts, and error completion paths to confirm slot state recovers cleanly.
- Check unsupported AHCI features fail explicitly rather than appearing to succeed partially.

## Integration Notes and Dependencies

This frontend depends on a SATA link path, descriptor memory, and a policy on how software discovers supported features. Integration should document the exact software contract so driver authors know which AHCI behaviors are preserved and which are intentionally absent.

## Edge Cases, Failure Modes, and Design Risks

- Exposing an AHCI-like interface without clearly bounding the subset can mislead driver software.
- Slot retirement bugs can leave the command issue map inconsistent after backend errors.
- If descriptor memory ordering is not defined, software may observe partial command consumption.

## Related Modules In This Domain

- sata_link_block
- storage_dma_engine
- reorder_buffer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the AHCI Lite Frontend module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
