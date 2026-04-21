# DRBG Block

## Overview

DRBG Block implements a cryptographically approved deterministic random bit generation process seeded from trusted entropy and auxiliary inputs. It provides a high-volume secure-random service with stateful reseed and request management.

## Domain Context

A deterministic random bit generator expands entropy input into cryptographically strong pseudorandom output for session keys, nonces, challenges, and internal protocol needs. In a hardware security architecture it sits downstream of true entropy collection and upstream of nearly every subsystem that needs secure randomness at scale.

## Problem Solved

True random sources are expensive, noisy, and often too slow or bursty to serve every immediate request directly. A dedicated DRBG turns scarce entropy into a managed random service while keeping reseed policy, prediction resistance, and state zeroization explicit.

## Typical Use Cases

- Supplying session keys, protocol nonces, and ephemeral secrets to secure accelerators.
- Providing challenge material for authentication and attestation flows.
- Smoothing entropy-source jitter by serving most requests from a reseeded deterministic core.
- Supporting compliance-oriented designs that need a documented DRBG state machine rather than ad hoc PRNG logic.

## Interfaces and Signal-Level Behavior

- Inputs include seed material, optional personalization string or additional input, generate request, and reseed request controls.
- Outputs provide pseudorandom words, request completion, and health or reseed-needed status.
- Control interfaces configure request size, prediction-resistance policy, and state-zeroization commands.
- Status signals often expose seeded, reseed_required, entropy_fault, and request_rejected indicators.

## Parameters and Configuration Knobs

- DRBG family or algorithm profile if more than one is supported.
- Internal state size and output block width.
- Maximum generate request size per invocation.
- Automatic reseed interval and prediction-resistance options.

## Internal Architecture and Dataflow

A DRBG Block usually contains internal state registers, a deterministic update and generate function, reseed logic, and policy gates tied to entropy availability. The architectural contract should define clearly whether entropy collection is external and whether the DRBG can refuse service until fresh reseed material arrives, because that behavior influences every consumer that treats randomness as always available.

## Clocking, Reset, and Timing Assumptions

The DRBG assumes its seed material ultimately originates from a trustworthy entropy source such as TRNG Block and that lifecycle controls prevent untrusted software from reading or cloning internal state. Reset should zeroize state and force reseed before use unless a retained secure state model is explicitly supported.

## Latency, Throughput, and Resource Considerations

Throughput is typically strong once seeded, with modest area cost compared with direct true-random servicing. Latency spikes occur at reseed boundaries or if entropy is unavailable. The important performance tradeoff is between always-on availability and strict reseed policy under degraded entropy conditions.

## Verification Strategy

- Check instantiate, reseed, generate, and uninstantiate flows against the chosen DRBG specification or reference model.
- Verify state changes on every request and ensure repeated outputs are not observed for repeated calls under the same conditions unless expected by test mode.
- Stress entropy-failure and reseed-required cases so request rejection or stalling behavior is safe and explicit.
- Confirm zeroization on reset and lifecycle transitions.

## Integration Notes and Dependencies

DRBG Block is typically fed by TRNG Block and serves Key Ladder, authenticated protocol wrappers, nonce generators, and secure software services. It should present clear quality and readiness signals so consumers know whether they are receiving fully seeded cryptographic randomness or are blocked pending entropy.

## Edge Cases, Failure Modes, and Design Risks

- A DRBG with ambiguous reseed policy can appear healthy while providing overused or stale pseudorandom output.
- Allowing software to clone, snapshot, or restore internal state can catastrophically undermine security.
- Confusing deterministic test mode with production mode is a classic path to shipping insecure randomness.

## Related Modules In This Domain

- trng_block
- key_ladder
- secure_boot_block
- tamper_monitor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the DRBG Block module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
