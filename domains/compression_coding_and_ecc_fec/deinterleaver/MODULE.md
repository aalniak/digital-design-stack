# Deinterleaver

## Overview

Deinterleaver reorders incoming symbols from an interleaved representation back into their original logical order. It provides the inverse permutation stage needed ahead of decoders or payload consumers.

## Domain Context

Deinterleaving is the receive-side inverse of interleaving in FEC and burst-error-mitigation systems. In this domain it exists to restore the original symbol ordering after a channel or storage medium has distributed errors across time or position.

## Problem Solved

Interleaving only helps if the receive side can reconstruct the intended symbol order exactly. A dedicated deinterleaver keeps permutation depth, block boundaries, and latency explicit rather than relying on ad hoc address arithmetic buried in larger decoders.

## Typical Use Cases

- Restoring symbol order before Viterbi, Reed-Solomon, or BCH decode.
- Undoing burst-spreading transformations in storage or communications records.
- Supporting standards that define exact matrix or block interleave geometry.
- Providing a reusable inverse permutation primitive for research FEC pipelines.

## Interfaces and Signal-Level Behavior

- Inputs are framed symbols or bytes plus block-boundary markers and possibly mode or permutation-profile select.
- Outputs provide reordered symbols with valid and block-complete signaling.
- Control interfaces configure permutation depth, matrix dimensions, and shortened-block handling.
- Status signals often expose block_active, permutation_error, and underflow or overflow conditions.

## Parameters and Configuration Knobs

- Permutation depth or interleave dimensions.
- Supported symbol width and block size.
- Streaming versus block-buffered implementation style.
- Static-profile versus dynamically programmed address map support.

## Internal Architecture and Dataflow

A deinterleaver usually contains address-generation logic, memory or FIFO storage, and block management that emits data only when the required reorder context is available. The architectural contract should define exactly which interleaver it inverts, because permutation compatibility matters more than any standalone notion of correctness.

## Clocking, Reset, and Timing Assumptions

The module assumes upstream framing preserves complete interleaver blocks or otherwise documents shortened-block semantics. Reset clears partial permutation state. If the design supports dynamic reconfiguration, changes should happen only between blocks so input and output ordering remain well defined.

## Latency, Throughput, and Resource Considerations

Resource use is dominated by the memory needed to hold enough symbols for the inverse permutation. Latency is at least one block or a significant fraction of one. The important performance metric is deterministic and correct reorder behavior under streaming stalls, not just raw throughput.

## Verification Strategy

- Run round-trip tests with the matching interleaver profile and confirm bit-exact inversion.
- Stress shortened or partial blocks and verify documented handling.
- Check dynamic profile switching only takes effect at safe boundaries.
- Verify address-generation logic against a software permutation model for all supported geometries.

## Integration Notes and Dependencies

Deinterleaver typically precedes BCH, Reed-Solomon, or Viterbi-style decoders and should align exactly with the paired Interleaver profile used on the transmit or storage-write side. It also interacts with packet framing because block boundaries often determine when reordered data becomes valid.

## Edge Cases, Failure Modes, and Design Risks

- A single off-by-one in block addressing can make every downstream decoder appear intermittently broken.
- Profile changes mid-block can silently corrupt whole frames.
- Assuming all interleavers are symmetric or trivially invertible can lead to incorrect reuse across standards.

## Related Modules In This Domain

- interleaver
- bch_codec
- reed_solomon_codec
- packet_deframer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Deinterleaver module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
