# RSA Modular Exponentiation

## Overview

RSA Modular Exponentiation computes modular exponentiation over large integers for RSA signature verification, decryption, or signing depending on configuration. It provides the core arithmetic engine required by RSA-based security flows.

## Domain Context

RSA modular exponentiation remains relevant in boot authentication, legacy certificate handling, and interoperability with established PKI ecosystems. In hardware it is the expensive big-number primitive that underlies RSA verification and, if enabled, private-key operations.

## Problem Solved

RSA operations are computationally heavy and easy to implement insecurely if timing, exponent handling, and key visibility are not defined clearly. A dedicated modular exponentiator isolates these concerns and gives secure wrappers a controlled arithmetic primitive to build on.

## Typical Use Cases

- Verifying RSA-signed boot images or certificates in legacy secure boot chains.
- Supporting interoperability with RSA-based manufacturing or update ecosystems.
- Offloading big-number modular arithmetic from constrained embedded CPUs.
- Running controlled research or validation workloads on asymmetric-crypto performance in hardware.

## Interfaces and Signal-Level Behavior

- Inputs usually include modulus, exponent, message or signature operand, operation mode, and start or valid handshakes.
- Outputs provide result words, completion status, and arithmetic fault or parameter validity indications.
- Control interfaces configure operand length, public-only versus private-key mode, and optional CRT support if present.
- Status outputs often expose busy, operand_invalid, and reduction-fault conditions.

## Parameters and Configuration Knobs

- Supported modulus sizes and word widths.
- Public-exponent-only versus generic exponent support.
- Montgomery or other reduction architecture selection.
- Whether private exponent paths, CRT acceleration, or blinding are implemented.

## Internal Architecture and Dataflow

Typical designs use Montgomery multiplication or a comparable modular arithmetic engine, operand memories, exponent sequencing, and result formatting. The critical architectural distinction is whether the block is intended solely for public-key verification or can also process private exponents, because private-key mode raises a much stronger bar for side-channel resistance, key routing, and zeroization guarantees.

## Clocking, Reset, and Timing Assumptions

The block assumes operands are validated for acceptable size and format before use or that the wrapper enforces such checks. Reset should clear intermediate big-number state and any private exponent material if present. If the design is verification-only, the documentation should say so plainly to discourage accidental private-key reuse in contexts it was never hardened for.

## Latency, Throughput, and Resource Considerations

RSA modular exponentiation is area and latency heavy, especially for large moduli. Throughput is usually low compared with symmetric crypto and acceptable for boot or certificate workloads. The more important performance question is whether the latency profile and storage footprint fit the target boot budget without weakening key handling.

## Verification Strategy

- Compare results against a trusted big-number reference for representative modulus sizes and exponents.
- Verify rejection or safe handling of malformed operands and unsupported sizes.
- Stress reset and aborted operations to confirm large intermediate registers are cleared.
- If private mode exists, validate blinding or other hardening features and their lifecycle gating.

## Integration Notes and Dependencies

RSA Modular Exponentiation is often wrapped by Secure Boot Block or certificate-validation logic and should obtain private keys only through strongly restricted paths if at all. It also depends on hash engines and policy wrappers that interpret padding schemes and signature formats correctly.

## Edge Cases, Failure Modes, and Design Risks

- A generic modexp core used for private keys without sufficient hardening can leak secret exponents badly.
- Padding-format handling belongs in the wrapper, and ambiguity there can lead to accepting invalid signatures despite correct arithmetic.
- Broad bus access to large private operands can negate the security value of hardware acceleration.

## Related Modules In This Domain

- secure_boot_block
- sha2_engine
- tamper_monitor
- ecc_p256_scalar_mult

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the RSA Modular Exponentiation module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
