# Key Ladder

## Overview

Key Ladder derives working keys from root or intermediate secrets through a sequence of cryptographic transforms while restricting key visibility and export. It provides the structured key-management path that feeds secure consumers without making every key a software-managed blob.

## Domain Context

A key ladder is the controlled key-derivation and key-wrapping backbone of a secure SoC. Its job is to derive operational keys from root material without broadly exposing plaintext keys to software or to untrusted buses, creating a hierarchy of trust anchored in device secrets.

## Problem Solved

Secure systems need many context-specific keys, but storing and moving all of them in plaintext raises attack surface dramatically. A dedicated key ladder localizes derivation, domain separation, and key export policy so consumers receive only the form of key material they are allowed to use.

## Typical Use Cases

- Deriving per-device, per-service, or per-session keys from OTP-rooted secrets.
- Feeding AES, HMAC, GCM, or secure-boot consumers through opaque key handles rather than plaintext keys.
- Supporting content-protection or secure-storage hierarchies with layered derivation stages.
- Enforcing lifecycle-specific access to manufacturing, field, or recovery key domains.

## Interfaces and Signal-Level Behavior

- Inputs usually include root-key selector or fused secret handle, derivation context, optional diversification data, and consumer binding or export policy.
- Outputs provide derived-key handles, wrapped key blobs, or direct feed into authorized crypto consumers rather than raw key words.
- Control interfaces configure derivation stage selection, algorithm choice, lifecycle constraints, and zeroization requests.
- Status signals often expose derivation_complete, policy_denied, key_invalid, and zeroize_done indications.

## Parameters and Configuration Knobs

- Number of derivation stages and supported root domains.
- Supported derivation primitives such as AES-based or hash-based expansion.
- Plaintext export disabled, wrapped export only, or consumer-bound delivery modes.
- Lifecycle and privilege gates controlling each stage or root key.

## Internal Architecture and Dataflow

A typical key ladder combines protected root storage references, context binding, derivation transforms, access-control checks, and consumer-specific output routing. The essential architectural contract is whether derived keys can ever appear in a general register file or memory map; in a strong design, most consumers should receive only opaque handles or dedicated internal key buses.

## Clocking, Reset, and Timing Assumptions

The ladder assumes its root material is anchored in OTP, eFuse, PUF, or another trusted secure source and that lifecycle state accurately reflects the device trust mode. Reset should zeroize intermediates and invalidate outstanding transient key handles. If plaintext export is supported for any reason, that exception should be explicitly scoped and ideally restricted to tightly controlled lifecycle modes.

## Latency, Throughput, and Resource Considerations

Key derivation is control-plane oriented, so throughput is less important than policy correctness and bounded latency. Resource cost depends on embedded crypto primitives and handle-tracking logic. The operational value lies in reducing key exposure, not in maximizing derivations per second.

## Verification Strategy

- Verify derivation determinism and domain separation across root selectors, contexts, and lifecycle states.
- Check that unauthorized consumers cannot obtain keys or reuse handles outside their intended binding.
- Stress reset, zeroization, and aborted derivation so intermediates are not retained.
- Validate that plaintext-export-disabled configurations truly block software-visible key reads.

## Integration Notes and Dependencies

Key Ladder sits at the center of the secure subsystem, serving AES, HMAC, GCM, Secure Boot Block, and update logic while consuming root material from OTP, PUF, or DRBG-enhanced diversification sources. It should align with lifecycle controls and tamper responses so key access contracts remain coherent under attack or debug modes.

## Edge Cases, Failure Modes, and Design Risks

- A key ladder that allows broad plaintext export provides little real isolation despite sophisticated derivation math.
- Poor domain separation can cause the same root secret to leak across unrelated protocol contexts.
- Handle binding that is only advisory, not enforced, can let one consumer misuse another consumer key.

## Related Modules In This Domain

- otp_efuse_controller
- puf_interface
- aes_core
- secure_boot_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Key Ladder module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
