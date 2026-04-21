# Secure Boot Block

## Overview

Secure Boot Block authenticates boot images and enforces boot policy before releasing execution to mutable firmware. It is the orchestration layer that converts cryptographic primitives and immutable state into a concrete chain-of-trust decision.

## Domain Context

Secure boot is the policy enforcement center of the hardware root of trust. It is the module that ties together immutable anchors, public-key or symmetric verification, anti-rollback state, lifecycle policy, and image metadata so the device only starts approved software.

## Problem Solved

Having hashes, signatures, and root secrets available in hardware does not automatically create a trustworthy boot flow. A dedicated secure-boot block is needed to define image parsing, key selection, rollback checks, failure policy, and which measurements or results are authoritative at each stage.

## Typical Use Cases

- Authenticating first-stage or second-stage firmware before execution.
- Enforcing anti-rollback and lifecycle-dependent boot policy.
- Measuring or reporting boot state to attestation logic or secure software.
- Supporting multiple image slots, recovery images, or staged update flows under one root-of-trust policy.

## Interfaces and Signal-Level Behavior

- Inputs generally include image metadata, image data stream or memory-read interface, lifecycle state, and immutable key or key-handle sources.
- Outputs provide boot_allow or boot_deny, verification result codes, selected image information, and optional measured-boot records.
- Control interfaces configure boot-source selection, allowed algorithms, recovery policy, and lifecycle exceptions.
- Status signals often expose signature_fail, rollback_fail, hash_fail, recovery_selected, and terminal_fault conditions.

## Parameters and Configuration Knobs

- Supported authentication schemes such as RSA, ECC, HMAC, or CMAC-based manifests.
- Number of boot sources or image slots.
- Recovery and fallback policy configuration.
- Whether measured-boot records, audit digests, or attestation handoff are produced.

## Internal Architecture and Dataflow

A secure boot block typically combines image parser and framer logic, digest or signature verification orchestration, root-key selection, anti-rollback compare, and final policy decision logic. The architectural contract should state exactly which stage is immutable, which policy comes from OTP versus firmware metadata, and whether recovery images are held to the same or a distinct trust policy.

## Clocking, Reset, and Timing Assumptions

The module assumes immutable keys or root state come from trusted anchors such as OTP, PUF, or masked ROM and that image storage is readable but not necessarily trusted. Reset should return the block to a no-execute state until verification completes. If measured boot is separate from enforcement, the documentation should distinguish those roles clearly so integrators do not mistake logging for gating.

## Latency, Throughput, and Resource Considerations

Boot-authentication latency depends on image size, hash throughput, and asymmetric verification cost. Throughput is secondary to correctness and fail-safe behavior. The most meaningful performance question is whether the system can authenticate quickly enough without relaxing verification or skipping rollback checks under time pressure.

## Verification Strategy

- Replay valid, corrupted, unsigned, downgraded, and recovery-image boot scenarios against the intended policy matrix.
- Verify that every boot failure mode leads to a deterministic and safe non-execution result unless documented recovery policy applies.
- Check image-slot selection, fallback, and rollback counter interactions across interrupted updates.
- Validate lifecycle-specific behavior so development flexibility does not weaken field boot enforcement.

## Integration Notes and Dependencies

Secure Boot Block is the main consumer of OTP or PUF roots, Key Ladder, hash engines, asymmetric accelerators, and Anti-Rollback Counter. It should also integrate with Tamper Monitor and debug policy so invasive or suspicious states can tighten or alter boot behavior rather than remain invisible to the root of trust.

## Edge Cases, Failure Modes, and Design Risks

- A boot block that logs failures but still exposes execution side effects before final decision is not fail-closed.
- Recovery and fallback rules are a common place where otherwise strong boot policy gets quietly weakened.
- If image metadata parsing is underspecified, wrapper bugs may invalidate the whole chain of trust despite strong crypto primitives.

## Related Modules In This Domain

- sha2_engine
- ecc_p256_scalar_mult
- rsa_modexp
- anti_rollback_counter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Secure Boot Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
