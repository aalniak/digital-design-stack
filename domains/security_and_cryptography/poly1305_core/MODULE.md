# Poly1305 Core

## Overview

Poly1305 Core computes or verifies Poly1305 authentication tags over framed message data using a one-time key input or a wrapped derivation path. It provides the authentication half of ChaCha20-Poly1305 and related constructions.

## Domain Context

Poly1305 is the one-time authenticator typically paired with ChaCha20 in modern AEAD constructions, though it can also serve in other one-time MAC settings. In hardware it complements stream-cipher datapaths by providing efficient per-message authentication with strict key and nonce-derivation assumptions.

## Problem Solved

Authenticated stream encryption needs more than keystream generation; it also needs a MAC that is integrated with the protocol one-time-key rules. A dedicated Poly1305 block makes accumulator arithmetic, final reduction, and tag formatting explicit so wrappers do not recreate those details inconsistently.

## Typical Use Cases

- Serving as the tag generator or verifier in ChaCha20-Poly1305 message protection.
- Authenticating framed records derived from one-time session subkeys.
- Accelerating authenticated command channels that standardize on Poly1305-based protection.
- Supporting protocol conformance and interoperability testing for AEAD hardware paths.

## Interfaces and Signal-Level Behavior

- Inputs include message stream, one-time Poly1305 key or key handle, framing markers, and mode selection for generate or verify.
- Outputs provide authentication tag, verify result, and completion signaling for each message context.
- Control interfaces configure padding or framing ownership, truncated-tag policy if any, and key-source mode.
- Status signals often expose busy, verify_fail, and malformed-message boundary conditions.

## Parameters and Configuration Knobs

- Datapath width and accumulator reduction strategy.
- Streaming versus packet-buffered operation.
- Generate-only versus generate-verify build option.
- Direct key load versus internal derivation from a higher-level AEAD wrapper.

## Internal Architecture and Dataflow

A typical Poly1305 implementation includes block parsing with the implicit high-bit convention, modular accumulation, multiplication by the r parameter, final addition of s, and optional compare logic. The key architectural contract is that the one-time authentication key must not be reused across messages, so the block documentation should say clearly whether it assumes a wrapper enforces that or whether it tracks message-key lifecycle itself.

## Clocking, Reset, and Timing Assumptions

Poly1305 assumes the supplied r and s values form a valid one-time key and that the calling construction guarantees nonreuse. Reset should clear accumulator state and any buffered key material. If verify mode is supported, tag comparison should use deterministic-latency logic rather than early-exit compare behavior.

## Latency, Throughput, and Resource Considerations

Area cost is moderate, dominated by wide multiply and reduction machinery. Throughput can be strong in streaming mode, with latency tied to message length plus final reduction. The true performance bottleneck in secure use is often message-boundary and one-time-key management, not arithmetic throughput.

## Verification Strategy

- Validate generate and verify behavior against standard Poly1305 test vectors and ChaCha20-Poly1305 combined references.
- Check padding and final-block treatment, especially for non-block-aligned messages.
- Stress reset, rekey, and back-to-back message handling to ensure one accumulator state never spans two messages.
- Verify integration assumptions around one-time-key handling, including explicit failure or misuse reporting if supported.

## Integration Notes and Dependencies

Poly1305 Core normally sits alongside ChaCha20 Core in an AEAD wrapper and should obtain its one-time key from a controlled derivation path rather than arbitrary software-visible memory. It often also depends on Constant Time Compare for verification semantics.

## Edge Cases, Failure Modes, and Design Risks

- Reusing a Poly1305 one-time key across messages destroys the security of the authenticator.
- If wrappers disagree about padding or AAD framing, interoperability failures may look like random tag mismatches.
- A correctly implemented core is still easy to misuse if the one-time-key lifecycle is not enforced or documented sharply.

## Related Modules In This Domain

- chacha20_core
- constant_time_compare
- key_ladder
- secure_boot_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Poly1305 Core module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
