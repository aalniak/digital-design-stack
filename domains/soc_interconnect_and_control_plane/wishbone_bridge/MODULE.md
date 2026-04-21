# Wishbone Bridge

## Overview

wishbone_bridge translates between Wishbone bus semantics and another local or standardized control-plane protocol while preserving address, data, completion, and fault behavior under a clear contract. It is the adaptation point for Wishbone integration.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

Wishbone remains common in some FPGA and legacy ecosystems, but many reusable blocks do not natively speak it. wishbone_bridge keeps protocol translation at the boundary rather than leaking Wishbone assumptions throughout the design.

## Typical Use Cases

- Connect a local register block to a Wishbone master.
- Adapt a Wishbone peripheral into a broader SoC fabric.
- Bridge between Wishbone control space and other bus protocols during integration.

## Interfaces and Signal-Level Behavior

- One side exposes Wishbone signals such as cyc, stb, we, adr, dat, sel, ack, err, and optional stall.
- The other side exposes a local request and response contract or another bus interface.
- Status may indicate unsupported transfer types or translation faults.

## Parameters and Configuration Knobs

- ADDRESS_WIDTH and DATA_WIDTH size the bridge.
- STALL_SUPPORT_EN defines whether backpressure is modeled with stall semantics.
- ERROR_MAP_MODE defines how faults translate between protocols.
- BYTE_SELECT_EN supports partial writes through select lines.
- PIPELINE_EN allows timing staging.

## Internal Architecture and Dataflow

A Wishbone bridge typically sequences request acceptance, target transaction issuance, and return acknowledgment in the style expected by Wishbone. The most important contract point is how Wishbone's acknowledge and optional stall behavior map onto the adapted side.

## Clocking, Reset, and Timing Assumptions

The bridge should document which Wishbone subset it supports, such as classic, pipelined, or narrower variants. Reset must leave the bridge idle with no partially acknowledged transfer. Unsupported features should be rejected explicitly.

## Latency, Throughput, and Resource Considerations

Wishbone bridges are usually low to moderate throughput. Cost is small, but careful sequencing is still needed to avoid deadlocks or double acknowledgments when the other side applies backpressure differently.

## Verification Strategy

- Check reads and writes with and without stall behavior.
- Exercise byte-select handling and partial writes.
- Verify error propagation and unsupported-feature policy.
- Compare translated transactions against a Wishbone reference model.

## Integration Notes and Dependencies

wishbone_bridge is useful when integrating legacy IP or FPGA-oriented ecosystems into a broader stack. It should state clearly whether it is intended for simple CSR-style traffic or more general memory-mapped behavior.

## Edge Cases, Failure Modes, and Design Risks

- Different Wishbone subsets can be confused if support is not scoped precisely.
- Acknowledge and stall timing bugs are easy to hide in directed tests.
- Silent dropping of unsupported cycle types is dangerous and should never be the default.

## Related Modules In This Domain

- apb_bridge
- tilelink_adapter
- axi_lite_slave
- address_decoder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Wishbone Bridge module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
