# Apb Bridge

## Overview

apb_bridge translates requests from another local or standardized control-plane protocol into APB transactions while preserving address, data, response, and timing semantics as faithfully as practical. It is the adaptation point into or out of APB-based peripheral space.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

APB is simple and peripheral-friendly, but many initiators speak a different control-plane dialect. apb_bridge provides the timing and response adaptation so peripherals do not each need a custom front end.

## Typical Use Cases

- Connect an AXI-lite or proprietary control master to APB peripherals.
- Expose a simple peripheral register bank behind a higher-level interconnect.
- Create a clean boundary between richer bus semantics and APB's two-phase transfer model.

## Interfaces and Signal-Level Behavior

- Source-side signals depend on the upstream protocol and usually include address, write data, strobes, and valid or ready semantics.
- APB-side outputs include PADDR, PWRITE, PSEL, PENABLE, PWDATA, and associated controls.
- Responses return PRDATA, PSLVERR, and completion mapped back into the source protocol.

## Parameters and Configuration Knobs

- ADDRESS_WIDTH and DATA_WIDTH size the transfer path.
- WAIT_STATE_SUPPORT_EN indicates whether APB wait-state handling is supported.
- ERROR_MAP_MODE defines how APB errors become upstream faults.
- OUTSTANDING_EN is typically false or minimal because APB is low concurrency by nature.
- BYTE_STROBE_POLICY defines how upstream strobes are interpreted or restricted.

## Internal Architecture and Dataflow

The bridge is usually a small FSM that captures an upstream request, drives APB setup and access phases, waits for readiness, and then returns data or status to the source side. The core challenge is preserving source-side backpressure and completion semantics while respecting APB's simple phase model.

## Clocking, Reset, and Timing Assumptions

APB is fundamentally low-throughput and low-concurrency, so callers should not assume burst or multi-outstanding behavior unless a wider wrapper makes that explicit. Reset should return the bridge to an idle, deselected APB state.

## Latency, Throughput, and Resource Considerations

Throughput is limited by APB transaction phasing and peripheral wait states. Hardware cost is small, but the bridge can become a serialization point if too many controls are funneled through it.

## Verification Strategy

- Check read and write transactions with and without APB wait states.
- Verify error propagation and timeout or stall policy if implemented.
- Exercise byte strobes and unsupported source-side features explicitly.
- Compare source-visible completion timing against a protocol reference model.

## Integration Notes and Dependencies

apb_bridge commonly pairs with address decoders, CSR banks, and simple peripherals. It is most effective when the rest of the interconnect treats APB as a low-speed leaf fabric rather than a high-throughput shared path.

## Edge Cases, Failure Modes, and Design Risks

- Source protocols with richer semantics can lose information if adaptation policy is not explicit.
- APB wait-state handling is easy to under-test.
- A stalled APB peripheral can freeze upstream control flow if the bridge has no timeout or watchdog policy.

## Related Modules In This Domain

- axi_lite_slave
- address_decoder
- csr_bank
- wishbone_bridge

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Apb Bridge module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
