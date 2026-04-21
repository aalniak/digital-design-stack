# SHA-3 Engine

## Overview

SHA-3 Engine computes Keccak-based digest functions and, in some builds, sponge-derived extendable outputs over framed message streams. It provides an alternative or complementary digest primitive to SHA-2 in the secure subsystem.

## Domain Context

SHA-3 provides a sponge-based alternative to SHA-2 for digesting, extendable-output functions, and designs that prefer Keccak-family constructions. In hardware security stacks it can support protocol agility, domain-separated hashing, and future-proofing where SHA-2 alone is not desired.

## Problem Solved

Some products need SHA-3 family support for standards alignment, protocol agility, or domain-separated sponge constructions that SHA-2 does not naturally provide. A dedicated engine avoids making those use cases depend on software-only implementations or poorly documented custom sponge logic.

## Typical Use Cases

- Hashing manifests or messages in systems that standardize on SHA-3-family digests.
- Supporting XOF-style or sponge-based constructions when the design includes them.
- Providing algorithm agility alongside SHA-2 for long-lived products.
- Enabling controlled evaluation of Keccak-based security primitives in hardware.

## Interfaces and Signal-Level Behavior

- Inputs typically include message stream, start and end markers, and function-selection controls for supported SHA-3 or XOF variants.
- Outputs provide digest or squeezed output words, completion signaling, and sometimes continue-squeeze status for XOF-capable builds.
- Control interfaces configure rate-capacity profile, output length, and whether the engine runs in fixed-digest or variable-output mode.
- Status signals often expose busy, absorb_ready, squeeze_valid, and malformed-length conditions.

## Parameters and Configuration Knobs

- Supported SHA3-224, SHA3-256, SHA3-384, SHA3-512, or XOF profiles if implemented.
- Internal permutation unrolling and datapath width.
- Fixed digest only versus digest plus extendable-output support.
- Whether intermediate sponge state is externally hidden, exported, or restorable under controlled conditions.

## Internal Architecture and Dataflow

The engine generally contains absorb framing, Keccak-f permutation control, state storage, padding-domain logic, and optional squeeze sequencing. The architectural contract should define exactly which domain-separation and padding rules are baked in for each supported mode, because sponge constructions are highly reusable but easy to misuse when mode boundaries are vague.

## Clocking, Reset, and Timing Assumptions

The block assumes callers select the right function profile and output length for the protocol at hand. Reset should clear full internal sponge state. If extendable output is supported, the documentation should state whether squeezing can continue after partial reads and how that behavior is bounded or reset.

## Latency, Throughput, and Resource Considerations

Area cost depends on permutation unrolling and state width. Latency is message-length dependent with an additional squeeze dimension for XOF modes. For most security workloads, correctness of absorb-finalize-squeeze sequencing matters more than maximum throughput.

## Verification Strategy

- Check all supported SHA-3 digests against standard known-answer vectors across varied message lengths.
- Verify padding and domain-separation behavior between fixed-digest and any XOF mode.
- Stress absorb followed by multiple squeeze windows if supported.
- Confirm reset and context switching fully clear sponge state and prevent message cross-contamination.

## Integration Notes and Dependencies

SHA-3 Engine can serve Secure Boot Block, higher-level hash wrappers, or protocol-agility layers and should align clearly with SHA-2 Engine usage so software knows which digest semantic each wrapper expects. If XOF modes exist, they should be exposed only where their streaming behavior is actually understood by consumers.

## Edge Cases, Failure Modes, and Design Risks

- Mode ambiguity between digest and XOF behavior can lead to subtle protocol incompatibility or misuse.
- If sponge state is externally restorable without care, unexpected state-sharing can arise across trust boundaries.
- Claiming algorithm agility without documenting which wrappers truly support SHA-3 can create a false sense of coverage.

## Related Modules In This Domain

- sha2_engine
- hmac_engine
- secure_boot_block
- drbg_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the SHA-3 Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
