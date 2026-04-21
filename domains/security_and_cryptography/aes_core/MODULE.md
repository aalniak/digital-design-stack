# AES Core

## Overview

AES Core performs Rijndael block encryption and, in some builds, decryption for fixed-width data blocks under a supplied key schedule or round-key interface. It provides the reusable hardware primitive behind higher-level secure protocols and storage schemes.

## Domain Context

The AES core is the baseline symmetric primitive for secure storage, secure transport, and authenticated boot pipelines in digital systems. In this security domain it is rarely used in isolation; it usually sits inside a larger key-management and protocol context where key residency, side-channel exposure, and mode-of-operation boundaries matter as much as raw cipher correctness.

## Problem Solved

Many secure subsystems need a trustworthy, reviewable AES implementation rather than burying cipher math inside each application block. A dedicated core makes key width, latency, key-schedule ownership, and side-channel assumptions explicit so surrounding modules can integrate it safely.

## Typical Use Cases

- Serving as the block cipher engine inside secure boot, key wrapping, and storage-encryption pipelines.
- Providing the cryptographic primitive used by authenticated modes such as GCM or CMAC.
- Accelerating symmetric encryption in embedded SoCs where software-only AES is too slow or exposes keys too broadly.
- Supporting lab validation of cipher throughput, latency, and key-schedule behavior in hardware.

## Interfaces and Signal-Level Behavior

- Inputs typically include plaintext or ciphertext block data, key material or expanded round keys, start or valid handshakes, and encrypt or decrypt mode when supported.
- Outputs provide processed block data, completion status, and sometimes ready or busy flow-control signals for pipelined integration.
- Control interfaces may configure key size, round count policy, and whether the key schedule is loaded internally or supplied externally.
- Status outputs often expose core_busy, key_valid, and fault or parity indications for hardened builds.

## Parameters and Configuration Knobs

- Supported key sizes such as 128, 192, and 256 bits.
- Encrypt-only versus encrypt-decrypt build option.
- Iterative, partially unrolled, or fully pipelined round architecture.
- Internal versus external key schedule ownership and round-key storage depth.

## Internal Architecture and Dataflow

Common implementations use an S-box layer, ShiftRows, MixColumns, AddRoundKey sequencing, and a companion key-schedule path. The key architectural contract is whether the core owns sensitive key expansion state internally or expects round keys from a protected outer key manager, because that decision determines where keys reside, how they are zeroized, and what must be hardened against probing or fault injection.

## Clocking, Reset, and Timing Assumptions

The core assumes key inputs arrive through a trusted path and are not exposed to untrusted bus masters. Reset should clear internal round state and, if key material is retained internally, zeroize it deterministically. If constant-latency or masked implementations are not provided, the documentation should state that side-channel hardening must be handled at the system level rather than implied by the presence of AES in hardware.

## Latency, Throughput, and Resource Considerations

Resource cost varies sharply between iterative and pipelined designs, with iterative cores favoring area and pipelined cores favoring throughput. Latency is generally one full round schedule per block unless heavily unrolled. Throughput matters, but in secure systems predictable completion timing and clean key-lifetime boundaries are often just as important as raw Gbps figures.

## Verification Strategy

- Compare encrypt and decrypt behavior against NIST known-answer vectors for all supported key widths.
- Check key reload, reset, and back-to-back block handling so no stale round state leaks across transactions.
- Stress malformed handshakes and partial key updates to ensure the core never uses mixed old and new key material.
- If hardened features exist, verify fault flags and key-zeroization behavior under injected error conditions.

## Integration Notes and Dependencies

AES Core is usually wrapped by mode engines, secure storage controllers, or boot-authentication logic rather than exposed directly to general software. It should integrate with Key Ladder or OTP-backed key sources so plaintext keys do not traverse wide shared buses unnecessarily, and with lifecycle controls that restrict use of manufacturing or debug-only keys.

## Edge Cases, Failure Modes, and Design Risks

- A mathematically correct AES core can still be insecure if key loading and zeroization semantics are weak.
- If decrypt mode shares logic with encrypt mode in an underdocumented way, latency and side-channel expectations may be misread by integrators.
- Placing plaintext key ports on a broadly accessible bus can erase most of the security value of having AES in hardware at all.

## Related Modules In This Domain

- aes_gcm_engine
- cmac_engine
- key_ladder
- secure_boot_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the AES Core module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
