# SHA-2 Engine

## Overview

SHA-2 Engine computes SHA-2 family digests over message streams or memory-backed payloads, typically supporting one or more standard output widths. It provides the reusable digest primitive behind manifests, keyed-hash constructions, and integrity checks.

## Domain Context

SHA-2 hashing is the digest foundation for secure boot, HMAC, certificate processing, measured boot, and many general integrity functions. In hardware security stacks it often becomes the most broadly reused primitive because so many higher-level policies and protocols depend on stable digest output.

## Problem Solved

Digest computation appears simple at the API level but requires correct padding, length accumulation, and streaming semantics to be trustworthy in hardware. A dedicated SHA-2 block keeps those rules centralized and reusable instead of duplicating them in every secure consumer.

## Typical Use Cases

- Hashing boot images and manifests during secure boot.
- Serving as the compression engine for HMAC implementations.
- Computing certificate or metadata digests in public-key verification flows.
- Providing measured-boot or audit hashes for attestation and logging pipelines.

## Interfaces and Signal-Level Behavior

- Inputs typically include message data stream, framing markers, hash-start or continue controls, and hash-family mode selection if configurable.
- Outputs provide final digest, intermediate state when explicitly supported, and completion or valid signals.
- Control interfaces configure SHA-224, SHA-256, SHA-384, or SHA-512 family support when present and define whether chaining state is externally visible.
- Status signals often expose busy, block_accept, message_length_error, and finalize_done conditions.

## Parameters and Configuration Knobs

- Supported SHA-2 variants and digest widths.
- Streaming versus memory-walk wrapper style.
- Internal round unrolling and datapath width.
- Whether intermediate chaining state is externally readable or reserved for trusted compositions only.

## Internal Architecture and Dataflow

A typical SHA-2 engine contains message schedule generation, compression rounds, length and padding logic, and digest-state storage. The architectural contract should define whether the engine is a pure hash primitive or also exposes chaining-state continuation hooks, because continuation support is useful for HMAC and large-system composition but can complicate trust boundaries if exposed casually to software.

## Clocking, Reset, and Timing Assumptions

The engine assumes callers provide explicit message boundaries and select the correct variant for the protocol in use. Reset should clear message-length and chaining state. If intermediate chaining state is exposed or restorable, that capability should be documented as a deliberate design choice with its intended trust model.

## Latency, Throughput, and Resource Considerations

SHA-2 engines range from iterative low-area designs to heavily pipelined high-throughput blocks. Boot and integrity workloads usually care about bounded image-hash latency more than bulk streaming benchmarks. Consistent finalization semantics and correct padding matter far more than a marginal throughput edge.

## Verification Strategy

- Run standard known-answer tests for every supported SHA-2 family and message length corner case.
- Check padding and total-length encoding, especially around block-boundary transitions.
- Verify reset, continue, and finalize sequencing so chained operations remain unambiguous.
- Stress long streaming messages and zero-length inputs against a trusted software reference.

## Integration Notes and Dependencies

SHA-2 Engine commonly feeds Secure Boot Block, HMAC Engine, and RSA or ECC signature wrappers that need message digests. It should integrate with DMA or image-reader wrappers carefully so framing and byte ordering match the expectations of higher-level manifest logic.

## Edge Cases, Failure Modes, and Design Risks

- A correct compression function is not enough if padding or length handling is even slightly wrong.
- Exposing intermediate chaining state broadly can make protocol misuse easier than intended.
- Byte-order mismatches between memory wrappers and the hash core can produce seemingly random signature failures that are hard to diagnose.

## Related Modules In This Domain

- hmac_engine
- secure_boot_block
- rsa_modexp
- sha3_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SHA-2 Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
