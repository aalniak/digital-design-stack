# ECC P-256 Scalar Multiply

## Overview

ECC P-256 Scalar Multiply computes point multiplication on the NIST P-256 elliptic curve for public-key operations such as signature verification, signing assistance, and key agreement. It provides the heavy arithmetic primitive underlying many modern asymmetric protocols.

## Domain Context

Scalar multiplication over the P-256 curve is the central arithmetic operation behind ECDSA verification and signing support, ECDH key exchange, and many secure-identity flows. In hardware security this module is one of the most timing- and side-channel-sensitive arithmetic blocks in the stack.

## Problem Solved

Public-key security operations are too slow or too exposed in software for some embedded systems, yet implementing curve arithmetic carelessly in hardware can leak key material or accept malformed points. A dedicated scalar multiplier makes curve model, input validation, and side-channel assumptions explicit.

## Typical Use Cases

- Accelerating ECDSA signature verification or signing support in secure boot and attestation flows.
- Performing ECDH shared-secret generation in secure channel establishment.
- Supporting device-identity and certificate-validation pipelines in hardware-rooted systems.
- Enabling controlled experimentation with public-key throughput and latency on embedded SoCs.

## Interfaces and Signal-Level Behavior

- Inputs generally include scalar value, input point coordinates or a reference to a stored public key, operation mode, and start or context controls.
- Outputs provide resulting point coordinates, completion status, and often validity or fault flags from arithmetic and input checks.
- Control interfaces configure scalar source handling, coordinate representation mode, and lifecycle gating for private-key operations.
- Status outputs may expose point_invalid, arithmetic_fault, and operation_busy indications.

## Parameters and Configuration Knobs

- Support for fixed-base, variable-base, or both multiplication modes.
- Coordinate system such as affine, Jacobian, or mixed representation.
- Internal field arithmetic width and multiplier architecture.
- Optional hardened features such as scalar blinding or projective randomization if implemented.

## Internal Architecture and Dataflow

A typical design combines modular add, subtract, multiply, inversion support or inversion avoidance, point-double and point-add control, and optional point-validation logic. The security-critical contract is whether private scalars ever traverse general-purpose buses and whether the operation schedule is constant with respect to scalar bits, because a functionally correct but data-dependent implementation can still be unacceptable in production security hardware.

## Clocking, Reset, and Timing Assumptions

The block assumes callers provide points on the correct curve or that point validation is explicitly enabled and enforced. Reset should zeroize private intermediates and abort any partial operation. If the design supports both public and private scalar use, the lifecycle and access controls governing private scalar entry must be documented very clearly.

## Latency, Throughput, and Resource Considerations

Resource cost is high compared with symmetric primitives, and latency can be hundreds or thousands of cycles depending on architecture. Throughput is usually secondary to robustness, constant-behavior properties, and clean integration with key-protection mechanisms.

## Verification Strategy

- Compare results against a trusted big-number or ECC reference for scalar multiplication, ECDH, and representative signature paths.
- Verify rejection or safe handling of invalid points, point at infinity, and malformed scalar inputs.
- Stress reset, abort, and fault-injection conditions so private intermediates are not retained.
- If hardened countermeasures exist, validate their enable policy and interaction with deterministic test modes.

## Integration Notes and Dependencies

ECC P-256 Scalar Multiply is commonly wrapped by Secure Boot Block, attestation engines, or certificate-validation logic and should obtain private scalars from protected storage or key-management paths. It also belongs alongside Tamper Monitor and lifecycle controls because public-key accelerators are frequent fault-injection targets.

## Edge Cases, Failure Modes, and Design Risks

- Missing or optional point validation can open invalid-curve or protocol-level attacks.
- A scalar multiplier that leaks timing or power proportional to secret bits undermines the value of hardware acceleration.
- Exposing raw private scalar ports broadly can make the arithmetic accelerator itself the easiest attack surface in the secure subsystem.

## Related Modules In This Domain

- rsa_modexp
- secure_boot_block
- key_ladder
- tamper_monitor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the ECC P-256 Scalar Multiply module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
