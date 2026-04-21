# Tilelink Adapter

## Overview

tilelink_adapter translates between the library's local control or memory-mapped semantics and TileLink protocol conventions while preserving ordering, capability, and response meaning as clearly as possible. It is the boundary block for TileLink integration.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

TileLink carries specific assumptions about channels, capabilities, and ordering that many local blocks do not natively express. tilelink_adapter concentrates that translation instead of forcing every local module to understand TileLink directly.

## Typical Use Cases

- Connect a local control block or memory endpoint to a TileLink fabric.
- Adapt a custom request interface to TileLink for SoC integration.
- Normalize TileLink-specific channel behavior at the boundary of reusable IP.

## Interfaces and Signal-Level Behavior

- One side exposes TileLink channel sets appropriate to the supported subset.
- The other side exposes a local request, response, or register-oriented contract.
- Status may indicate unsupported TileLink operations or adaptation faults.

## Parameters and Configuration Knobs

- TL_SUBSET defines the supported TileLink profile or channel subset.
- ADDRESS_WIDTH and DATA_WIDTH size the adapted transaction view.
- SOURCE_ID_WIDTH defines concurrency or source tracking support.
- ATOMIC_SUPPORT_EN declares whether atomics are passed, emulated, or rejected.
- PIPELINE_EN allows timing staging.

## Internal Architecture and Dataflow

The adapter usually translates TileLink requests into a simpler local transaction form and reconstructs TileLink responses on the way back. The main contract questions are which TileLink features are truly supported and which are deliberately rejected or simplified.

## Clocking, Reset, and Timing Assumptions

Not every local block can support the full TileLink feature set. The adapter should document exactly which operations, permissions, and ordering guarantees survive translation. Reset should clear any in-flight source bookkeeping.

## Latency, Throughput, and Resource Considerations

Performance depends on supported concurrency and how closely the local side resembles TileLink semantics already. Cost rises when source tracking, atomics, or feature emulation are included.

## Verification Strategy

- Exercise every supported TileLink operation and reject unsupported ones explicitly.
- Verify source tracking and response association.
- Check ordering behavior under concurrent requests if supported.
- Compare adapted traffic against a protocol-aware reference model.

## Integration Notes and Dependencies

tilelink_adapter is most useful when TileLink is an integration requirement but the reusable module itself should remain protocol-agnostic internally. Clear feature scoping matters more than trying to support everything.

## Edge Cases, Failure Modes, and Design Risks

- Claiming support for more TileLink features than the local side can actually honor is dangerous.
- Source or capability tracking bugs can silently violate protocol guarantees.
- Feature rejection must be explicit or unsupported traffic may hang.

## Related Modules In This Domain

- wishbone_bridge
- apb_bridge
- axi_lite_slave
- transaction_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Tilelink Adapter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
