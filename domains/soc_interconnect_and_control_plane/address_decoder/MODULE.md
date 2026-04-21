# Address Decoder

## Overview

address_decoder maps an incoming address or transaction to one of several target regions and emits the select, local offset, or fault indication needed by downstream logic. It is the basic address-map realization primitive in the control plane.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

A shared interconnect needs one clear source of truth for region ownership. Ad hoc decode logic scattered across blocks leads to overlapping regions, unmapped holes, and inconsistent fault handling. address_decoder centralizes that mapping.

## Typical Use Cases

- Route bus transactions to peripherals or memory windows.
- Derive local address offsets after region selection.
- Detect unmapped or reserved address accesses and surface a controlled fault.

## Interfaces and Signal-Level Behavior

- Inputs usually include address and request-valid qualifiers plus optional transaction attributes.
- Outputs include region select, local decoded address, and optional decode-error indication.
- Some variants also emit one-hot target enables or encoded target IDs for downstream muxing.

## Parameters and Configuration Knobs

- ADDRESS_WIDTH sets decoded address size.
- NUM_REGIONS sizes the region table.
- REGION_MODE selects base-mask or start-end style decode.
- DEFAULT_FAULT_EN enables explicit unmapped-region reporting.
- PRIORITY_POLICY defines behavior if regions overlap, though overlap should ideally be illegal.

## Internal Architecture and Dataflow

The decoder usually compares the incoming address against a set of configured windows, generates a target select, and subtracts or masks off the base to form a local address. The most important design point is deterministic handling of unmapped or accidentally overlapping regions.

## Clocking, Reset, and Timing Assumptions

The global address map must be authoritative and stable for the lifetime of the instance or be updated in a carefully controlled way. Reset should define whether configuration is static or software-programmable.

## Latency, Throughput, and Resource Considerations

Address decode is usually combinational and can fall on the front edge of a bus critical path, especially with many regions. Hierarchical decode or pipelining may be appropriate in larger maps.

## Verification Strategy

- Check selection and local offset across the full address map.
- Exercise holes, boundaries, and adjacent windows.
- Verify unmapped and overlapping-region behavior.
- Compare generated routing decisions against a software address-map model.

## Integration Notes and Dependencies

address_decoder sits underneath bridges, crossbars, CSR banks, and bus fabrics. Stable and explicit decode semantics reduce a large class of control-plane integration bugs.

## Edge Cases, Failure Modes, and Design Risks

- Overlapping or ambiguous regions are a major system hazard.
- Boundary off-by-one errors often escape until software integration.
- Fault behavior for unmapped addresses must be explicit or masters will hang unpredictably.

## Related Modules In This Domain

- bus_crossbar
- apb_bridge
- axi_lite_slave
- csr_bank

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Address Decoder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
