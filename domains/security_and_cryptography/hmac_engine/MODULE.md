# HMAC Engine

## Overview

HMAC Engine computes or verifies keyed hash-based message authentication codes using an underlying SHA-family digest engine. It provides a reusable keyed-integrity primitive for control-plane and identity-oriented security flows.

## Domain Context

HMAC is the keyed-hash authentication primitive widely used in secure boot manifests, API authentication, attestation, and provisioning protocols. In hardware it offers a flexible integrity and origin-authentication block built around SHA-family hashes rather than block-cipher modes.

## Problem Solved

Many systems need authentication that composes naturally with hash-based workflows and existing certificate or manifest formats. A dedicated HMAC engine standardizes key padding, inner and outer digest sequencing, and verify policy so wrappers do not improvise these details.

## Typical Use Cases

- Authenticating signed-but-also-keyed control messages or provisioning commands.
- Protecting API-like command channels in embedded controllers.
- Providing keyed digest generation for attestation, integrity manifests, or audit records.
- Accelerating software-visible HMAC services without exposing hash-internal sequencing complexity.

## Interfaces and Signal-Level Behavior

- Inputs typically include message stream, secret key or key reference, start and end framing markers, and mode selection for generate versus verify.
- Outputs provide MAC value, verify result, and completion signaling for each message.
- Control interfaces configure the underlying hash family, truncation policy, and key-source mode.
- Status signals often expose busy, verify_fail, and malformed-message or key-loading errors.

## Parameters and Configuration Knobs

- Supported hash families such as SHA-256 or SHA-512 if the implementation is configurable.
- Streaming versus block-buffered message style.
- Tag truncation width and padding ownership.
- Internal versus external key preprocessing support.

## Internal Architecture and Dataflow

The engine generally wraps a SHA2 Engine or similar digest core with key normalization, inner digest pass, outer digest pass, and optional verify compare. The important contract is whether key preprocessing and ipad or opad expansion are internal and protected, because that determines where raw secret keys reside and whether software has to stage preprocessed values in less trusted memory.

## Clocking, Reset, and Timing Assumptions

HMAC Engine assumes message framing is explicit and that the selected hash variant is fixed per context. Reset should clear partial digest state and any retained key-derived pads. If verify mode is present, the tag-compare step should use Constant Time Compare or an equivalent deterministic-latency strategy.

## Latency, Throughput, and Resource Considerations

Latency is higher than a single hash pass because HMAC requires inner and outer digests. Throughput remains useful for command and manifest traffic, though typically not line-rate data encryption workloads. The main performance concern is predictable message-boundary behavior rather than raw bytes per second.

## Verification Strategy

- Validate generation and verification against known-answer vectors for each supported hash family and truncation mode.
- Check key normalization for keys shorter and longer than the block size.
- Stress empty, single-block, and long streaming messages to ensure inner and outer pass framing remains correct.
- Verify reset and context switch behavior so one key or partial digest cannot contaminate the next transaction.

## Integration Notes and Dependencies

HMAC Engine commonly relies on SHA2 Engine and protected key sources such as Key Ladder or OTP-backed secrets. It often feeds Secure Boot Block, provisioning command processors, and authenticated maintenance channels.

## Edge Cases, Failure Modes, and Design Risks

- If key preprocessing is done outside the protected block without care, the secret may be more exposed than expected.
- A correct hash engine alone does not guarantee correct HMAC if inner or outer padding rules are mishandled.
- Leaky compare behavior in verify mode can undo the value of otherwise clean HMAC computation.

## Related Modules In This Domain

- sha2_engine
- constant_time_compare
- secure_boot_block
- key_ladder

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the HMAC Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
