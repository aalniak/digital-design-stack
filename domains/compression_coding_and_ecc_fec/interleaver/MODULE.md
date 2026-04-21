# Interleaver

## Overview

Interleaver permutes outgoing symbols into a reordered sequence designed to disperse burst errors across a wider logical span. It provides the forward permutation stage paired with a deinterleaver on the receive side.

## Domain Context

Interleaving is the transmit-side or write-side mechanism that spreads adjacent logical symbols apart so burst errors are turned into more correctable random-looking errors. In this domain it is a memory-based permutation primitive that supports stronger downstream ECC performance.

## Problem Solved

Many FEC schemes handle random errors better than clustered ones. A dedicated interleaver allows a system to shape the error pattern seen by the decoder without embedding custom permutation logic in every communication or storage pipeline.

## Typical Use Cases

- Spreading burst channel errors before Viterbi, BCH, or Reed-Solomon protection.
- Preparing storage records for media with localized corruption behavior.
- Implementing standards-defined block or matrix interleaves in hardware.
- Studying burst-error mitigation tradeoffs in research communication chains.

## Interfaces and Signal-Level Behavior

- Inputs are logical-order symbols plus block-boundary markers and optional profile selection.
- Outputs provide interleaved symbols with valid and block-complete status.
- Control interfaces configure permutation dimensions, depth, and shortened-block handling.
- Status signals often expose block_active, permutation_ready, and configuration errors.

## Parameters and Configuration Knobs

- Permutation dimensions or interleave depth.
- Supported symbol width and block size.
- Streaming versus fully buffered implementation style.
- Static-profile versus programmable address-map support.

## Internal Architecture and Dataflow

An interleaver typically uses address generation and RAM or FIFO resources to reorder symbols into a transmission sequence. The contract should define exactly how input order maps to output order and what block size is assumed, because that mapping must match the paired deinterleaver precisely.

## Clocking, Reset, and Timing Assumptions

The block assumes complete logical blocks are framed correctly by upstream logic. Reset clears any partially filled interleave buffer. If profile changes are supported, they should occur only between blocks so the emitted permutation remains coherent.

## Latency, Throughput, and Resource Considerations

Memory depth dominates resource cost. Latency is block-related and therefore nontrivial. The meaningful performance question is whether the chosen depth provides enough burst spreading for the intended channel while still fitting system buffering and latency budgets.

## Verification Strategy

- Validate output ordering against a software model for each supported profile.
- Run round-trip tests with the paired deinterleaver to confirm exact inversion.
- Stress shortened blocks, backpressure, and profile changes at boundaries.
- Check that no symbols are dropped or duplicated during block turnover.

## Integration Notes and Dependencies

Interleaver usually sits before FEC encode and after higher-level framing or tokenization. It should align with Deinterleaver, Packet Framer, and codeword structure so interleave blocks do not accidentally cross protocol boundaries that should remain independently decodable.

## Edge Cases, Failure Modes, and Design Risks

- Crossing the wrong framing boundary with one interleave block can amplify recovery problems instead of reducing them.
- A profile mismatch between encode and decode sides may resemble random channel failure rather than a deterministic bug.
- Interleaving too deeply can improve correction but break latency budgets elsewhere in the system.

## Related Modules In This Domain

- deinterleaver
- bch_codec
- reed_solomon_codec
- packet_framer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Interleaver module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
