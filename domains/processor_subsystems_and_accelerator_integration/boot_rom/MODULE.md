# Boot ROM

## Overview

Boot ROM stores immutable boot instructions or boot metadata and presents them through the processor memory map at reset. It provides the first trusted or fixed boot-stage content for processor startup.

## Domain Context

Boot ROM is the immutable first code and metadata source the processor subsystem sees after reset. In this domain it anchors the software-visible boot path and often coordinates with secure or platform boot policy before mutable firmware takes over.

## Problem Solved

Without a stable immutable starting point, every platform reset path becomes ambiguous and hard to verify. A dedicated Boot ROM block makes reset fetch behavior, contents ownership, and patch or alias policy explicit.

## Typical Use Cases

- Providing first-stage boot code for a processor subsystem.
- Anchoring secure or measured boot handoff to mutable storage.
- Supplying immutable diagnostics or recovery vectors.
- Establishing a deterministic reset fetch target for bring-up and manufacturing test.

## Interfaces and Signal-Level Behavior

- Inputs include read addresses from the processor or fabric, reset and boot-mode qualifiers, and optional patch or alias controls.
- Outputs provide instruction or data words plus ready or error status as appropriate to the memory interface.
- Control interfaces configure address aliasing, version exposure, and optional lifecycle-gated patch assist if supported.
- Status signals may expose ROM_selected and patch_active indications.

## Parameters and Configuration Knobs

- ROM size, data width, and memory interface style.
- Address alias or mirror support.
- Optional patch window or indirection support.
- Version or build-ID metadata exposure.

## Internal Architecture and Dataflow

The block is typically a read-only memory array or macro with optional decode aliases and tightly controlled patch hooks. The architectural contract should define whether contents are truly immutable in production and how any patch or redirection mechanism is constrained, because boot trust and recovery behavior depend on that answer.

## Clocking, Reset, and Timing Assumptions

The module assumes its contents match the platform reset vector and expected software-visible map. Reset should make Boot ROM immediately readable or fetchable according to platform timing requirements. If secure boot or lifecycle policy depends on Boot ROM code, the boundary between hardware policy and ROM firmware policy should be explicit.

## Latency, Throughput, and Resource Considerations

Boot ROM is small and latency is usually low, but early boot performance can still depend on width and wait-state policy. The key tradeoff is between a tiny simple ROM and one that includes enough immutable utility or recovery code to simplify the rest of the platform.

## Verification Strategy

- Verify reset fetch mapping and address alias behavior.
- Check ROM contents and version reporting against the intended boot image.
- Stress patch or redirect mechanisms if present, including their lifecycle gating.
- Run end-to-end boot tests to ensure the processor wrapper and ROM agree on reset entry behavior.

## Integration Notes and Dependencies

Boot ROM connects directly to the core wrapper or memory hierarchy and often cooperates with Debug Module and secure boot policy. It should align with the software memory map and with the immutable portion of the platform boot strategy.

## Edge Cases, Failure Modes, and Design Risks

- A boot vector mismatch between wrapper and ROM can stall bring-up entirely.
- Patchable ROM features can weaken the trust anchor if not gated tightly.
- If immutable boot code owns policy that hardware assumes elsewhere, ambiguities arise between firmware and hardware responsibilities.

## Related Modules In This Domain

- riscv_core_wrapper
- debug_module
- instruction_cache
- scratchpad_tcm

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Boot ROM module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
