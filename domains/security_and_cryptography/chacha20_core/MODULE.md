# ChaCha20 Core

## Overview

ChaCha20 Core generates the ChaCha20 keystream and performs stream encryption or decryption by XORing that keystream with payload data. It provides a high-throughput, counter-based symmetric primitive suitable for packet and record protection.

## Domain Context

ChaCha20 is a stream-cipher primitive valued in many embedded and protocol contexts for software and hardware simplicity, good performance on small systems, and clean pairing with Poly1305 in authenticated-encryption designs. In a hardware stack it offers a non-AES symmetric path with different implementation tradeoffs.

## Problem Solved

Some systems need an efficient non-AES primitive for standards compliance, protocol interoperability, or implementation diversity. A dedicated ChaCha20 hardware core clarifies counter handling, nonce format, and keystream-block sequencing so protocol wrappers do not each reimplement them.

## Typical Use Cases

- Serving as the encryption component in ChaCha20-Poly1305 authenticated encryption.
- Accelerating software-defined secure channels on small embedded SoCs.
- Providing a stream cipher for low-latency record or packet protection.
- Supporting side-by-side evaluation of AES-based and ChaCha-based secure datapaths.

## Interfaces and Signal-Level Behavior

- Inputs typically include key, nonce, block counter, payload data stream, and start or frame boundary markers.
- Outputs provide keystream or XOR-processed payload, block-done status, and counter progression information.
- Control interfaces configure nonce format, block-counter initialization, and encrypt-stream framing behavior.
- Status signals often expose busy, counter_wrap, and invalid-parameter conditions.

## Parameters and Configuration Knobs

- Round count, typically fixed to the ChaCha20 profile.
- Datapath width and degree of quarter-round unrolling.
- Direct keystream-output mode versus integrated XOR mode.
- Internal or external block-counter management policy.

## Internal Architecture and Dataflow

Implementations usually consist of the ChaCha state matrix, quarter-round scheduler, block-function datapath, and XOR or keystream output stage. The critical contract is whether the core emits raw keystream, transformed payload, or both, because exposing raw keystream can be useful for composition but also easier to misuse if counter and nonce management are weak.

## Clocking, Reset, and Timing Assumptions

The core assumes callers enforce nonce uniqueness for each key and manage block-counter bounds correctly unless the wrapper does that internally. Reset should clear key-derived state and restart counter tracking from a documented invalid or idle condition. If the design is not masked or fault-hardened, system-level side-channel assumptions should be spelled out.

## Latency, Throughput, and Resource Considerations

ChaCha20 can achieve very strong throughput per area with moderate unrolling. Latency is block based and predictable. Performance is often attractive for streaming interfaces, but nonce and counter semantics still dominate the real security value of the block.

## Verification Strategy

- Check against RFC known-answer vectors for keystream and full payload transform.
- Verify counter increment, wrap detection, and block-boundary behavior across long streams.
- Stress reset and rekey timing to ensure no keystream block mixes old and new key state.
- If raw keystream output is supported, confirm gating and mode separation prevent accidental misuse in wrappers.

## Integration Notes and Dependencies

ChaCha20 Core typically pairs with Poly1305 Core inside authenticated-encryption wrappers and should be fed by a key manager rather than general software whenever possible. It also belongs behind framing logic that owns nonce formatting and message boundary semantics.

## Edge Cases, Failure Modes, and Design Risks

- A nonce-management error can completely break security even when the core math is perfect.
- Exposing raw keystream without careful wrapper policy can encourage insecure composition.
- Counter wrap handling that is only diagnostic, not blocking, may let long streams become unsafe under corner cases.

## Related Modules In This Domain

- poly1305_core
- key_ladder
- secure_boot_block
- constant_time_compare

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ChaCha20 Core module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
