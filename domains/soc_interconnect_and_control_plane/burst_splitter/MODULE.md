# Burst Splitter

## Overview

burst_splitter decomposes a larger transaction into several smaller bursts to satisfy downstream limits on length, alignment, boundary crossing, or target capability. It is the safety-oriented counterpart to burst_merger.

## Domain Context

In the SoC Interconnect and Control Plane domain, modules are judged by how clearly they define transaction ownership, ordering, address interpretation, backpressure, sideband propagation, and software-visible control behavior. These blocks are where protocol mismatches become system integration bugs if contracts are vague.

## Problem Solved

A source may generate bursts that are legal locally but not acceptable to a target fabric or memory. burst_splitter enforces those target constraints without forcing every source to understand them directly.

## Typical Use Cases

- Split long DMA bursts to match peripheral or memory-controller limits.
- Break transactions at page, row, or region boundaries.
- Adapt one initiator to several targets with different burst capabilities.

## Interfaces and Signal-Level Behavior

- Inputs generally include address, length, beat size, and transaction intent.
- Outputs emit one or more smaller bursts toward the target side.
- Status may record how the original transaction was partitioned and whether any split occurred.

## Parameters and Configuration Knobs

- MAX_OUT_BURST defines target burst limit.
- BOUNDARY_MODE defines split points such as page or region boundaries.
- RESPONSE_REASSEMBLY_EN indicates whether source-side completion is aggregated back into one result.
- ATTRIBUTE_PROP_POLICY defines how source attributes propagate to child bursts.
- OUTSTANDING_CHILDREN sets allowed concurrent split sub-bursts.

## Internal Architecture and Dataflow

The splitter usually includes a length counter, address generator, and child-burst emission logic that walks the original transaction until all beats are represented. It may also maintain parent-child bookkeeping so completions from several target bursts map back to one source request.

## Clocking, Reset, and Timing Assumptions

The source side must know whether a single completion still represents the whole original burst or whether child-burst progress is visible. Split rules such as page or protection-region boundaries should be explicit and deterministic.

## Latency, Throughput, and Resource Considerations

Splitting improves compatibility but usually adds command overhead and bookkeeping. Throughput depends on whether child bursts can overlap and whether completion aggregation is lightweight or stateful.

## Verification Strategy

- Split transfers across every supported boundary type.
- Exercise exact-limit and just-over-limit lengths.
- Verify parent-to-child completion accounting.
- Check that unsplittable or already legal bursts pass through unchanged.

## Integration Notes and Dependencies

burst_splitter typically precedes bridges, masters, or target-specific controllers with tighter limits than the source side. It is often a companion to burst_merger and burst_adapter.

## Edge Cases, Failure Modes, and Design Risks

- Child-burst completion bookkeeping is easy to get wrong.
- A boundary rule omitted from the splitter will appear only in target-specific failures.
- Exposing partial child-burst progress to a source that assumes atomic completion can break higher-level logic.

## Related Modules In This Domain

- burst_merger
- burst_adapter
- axi4_master
- transaction_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Burst Splitter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
