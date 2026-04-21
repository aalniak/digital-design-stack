# AES-GCM Engine

## Overview

AES-GCM Engine performs authenticated encryption and authentication tag generation or verification using AES in counter mode plus GHASH. It packages both confidentiality and integrity into a single reusable hardware primitive for packet or record protection.

## Domain Context

AES-GCM is the authenticated-encryption workhorse for many secure communication and storage paths. In a hardware security stack it is the module that combines confidentiality and integrity in one contract, provided nonce management, tag verification policy, and key handling are all treated as first-class concerns.

## Problem Solved

Designs often need more than raw AES block transforms; they need a mode engine that handles IV formation, counter sequencing, additional authenticated data, and tag verification correctly. A dedicated GCM engine prevents every subsystem from reinventing these failure-prone details.

## Typical Use Cases

- Protecting firmware images, secure channels, or stored records with authenticated encryption.
- Serving as the crypto offload engine for link-layer or application-layer secure messaging.
- Verifying integrity and authenticity of encrypted content during secure update flows.
- Supporting deterministic test and validation of AEAD behavior in a hardware-centric environment.

## Interfaces and Signal-Level Behavior

- Inputs generally include plaintext or ciphertext streams, nonce or IV material, AAD stream, key reference or key input, and mode selection for encrypt or decrypt verify.
- Outputs provide protected or recovered payload, authentication tag, tag-valid result, and end-of-message status.
- Control interfaces configure tag length, message framing, counter initialization policy, and failure-handling behavior for tag mismatches.
- Status signals often expose busy, tag_mismatch, nonce_error, and stream-boundary integrity conditions.

## Parameters and Configuration Knobs

- Supported tag lengths and nonce formatting rules.
- Streaming versus packet-buffered datapath style.
- Internal GHASH implementation width and pipelining depth.
- Key-source mode, including direct key load versus key-manager handle input.

## Internal Architecture and Dataflow

The engine typically combines an AES counter-mode datapath, GHASH multiplier over GF(2^128), framing logic for AAD and payload, and tag compare or emit logic. The security-critical contract is that the engine must define clearly when decryption output becomes visible relative to tag verification, because some systems can tolerate speculative plaintext exposure and others absolutely cannot.

## Clocking, Reset, and Timing Assumptions

The engine assumes nonce or IV uniqueness is enforced by the calling system unless the block itself includes monotonic or managed nonce generation. Reset should clear partial authentication state and any buffered key-derived data. If decrypted data is released before final tag confirmation, that behavior must be called out plainly so integrators do not mistake the engine for a fail-closed design.

## Latency, Throughput, and Resource Considerations

Resource cost is higher than bare AES because GHASH and framing machinery run alongside the cipher core. Throughput can be excellent with pipelining, but latency at packet boundaries and tag verification completion often dominates integration decisions. Deterministic framing semantics and clear error signaling matter as much as line rate.

## Verification Strategy

- Run NIST and protocol-specific GCM known-answer vectors covering encrypt, decrypt, AAD, and varied tag lengths.
- Stress nonce reuse rejection or reporting policy if the block manages nonce state internally.
- Verify tag-mismatch behavior, especially whether plaintext is suppressed, flagged late, or already emitted.
- Check counter rollover, partial final blocks, and zero-length AAD or payload edge cases.

## Integration Notes and Dependencies

AES-GCM Engine usually sits behind DMA, packet, or storage-framing layers and should integrate with Key Ladder or OTP-sourced keys to minimize plaintext key movement. It also belongs in a larger nonce-management policy, because no local datapath correctness can compensate for systemic IV misuse.

## Edge Cases, Failure Modes, and Design Risks

- A correct AES-GCM datapath is still dangerous if nonce uniqueness is left vague or unenforced.
- If tag-failure handling is ambiguous, downstream logic may accidentally trust unauthenticated plaintext.
- Mixing AAD and payload framing incorrectly can create rare interoperability or security failures that are hard to diagnose.

## Related Modules In This Domain

- aes_core
- key_ladder
- secure_boot_block
- constant_time_compare

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the AES-GCM Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
