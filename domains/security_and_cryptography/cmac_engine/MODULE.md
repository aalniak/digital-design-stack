# CMAC Engine

## Overview

CMAC Engine computes or verifies AES-CMAC authentication values over a framed message stream using a supplied key or protected key handle. It provides a block-cipher-based integrity primitive for control-plane and provisioning use cases.

## Domain Context

CMAC is the message-authentication construction that repurposes AES into a standardized integrity primitive for fixed or variable-length messages. In a hardware security stack it is often used for key confirmation, command authentication, and provisioning flows where a full AEAD datapath would be unnecessary or awkward.

## Problem Solved

Systems frequently need integrity and authenticity without necessarily needing encryption. A dedicated CMAC block standardizes subkey generation, block padding, and final-tag handling so application logic does not reimplement these easy-to-misstep details.

## Typical Use Cases

- Authenticating secure commands, manifests, or provisioning payloads.
- Performing key confirmation and lightweight integrity checks in embedded protocols.
- Providing a standardized MAC primitive in environments where AES infrastructure already exists.
- Supporting deterministic hardware validation of CMAC generation and verify behavior.

## Interfaces and Signal-Level Behavior

- Inputs generally include message data stream, key or key reference, message boundary markers, and mode selection for generate versus verify.
- Outputs provide authentication tag, compare result, and completion status for each message context.
- Control interfaces configure tag truncation policy, framing behavior, and key-source mode.
- Status signals often expose busy, verify_fail, and malformed-frame or padding-condition errors.

## Parameters and Configuration Knobs

- Supported tag output widths and truncation modes.
- Streaming versus block-buffered framing style.
- Internal subkey-generation ownership versus externally supplied precomputed subkeys.
- Key source options such as direct load, key ladder handle, or secure memory reference.

## Internal Architecture and Dataflow

The engine typically combines an AES Core, subkey derivation for K1 and K2, CBC-MAC style accumulation, final-block handling, and optional tag comparison. The key architectural decision is whether verification releases a boolean result only at end-of-message or also exposes intermediate state for debug, because intermediate MAC visibility can weaken the intended trust boundary if not tightly controlled.

## Clocking, Reset, and Timing Assumptions

CMAC assumes message boundaries are explicit and the calling system knows whether truncation is acceptable for the target protocol. Reset should clear partial accumulation state and any retained subkeys or key material. If verify mode uses a comparison helper, the design should ensure the compare path does not create secret-dependent timing or observable early-exit behavior.

## Latency, Throughput, and Resource Considerations

Resource cost is modest when reusing an AES datapath and scales with the chosen streaming architecture. Latency is message-length dependent, with one finalization step for the last block. Throughput is usually less critical than predictable end-of-message behavior and key-lifetime clarity.

## Verification Strategy

- Validate generation and verification against standard CMAC known-answer vectors, including empty and non-block-aligned messages.
- Check subkey derivation and final-block padding behavior explicitly.
- Stress truncated-tag modes and verify-fail cases to ensure error handling is consistent and non-leaky.
- Confirm reset and context switch behavior so partial message state cannot contaminate the next operation.

## Integration Notes and Dependencies

CMAC Engine usually wraps AES Core and may use Constant Time Compare for verify mode. It often integrates with Key Ladder, secure provisioning logic, or boot policy blocks that need lightweight message authentication without full confidentiality.

## Edge Cases, Failure Modes, and Design Risks

- A correct AES datapath can still yield wrong CMAC if final-block rules or subkey handling are underdocumented.
- Exposing intermediate MAC state for convenience can undermine protocol security assumptions.
- Verification flows that short-circuit or report detailed mismatch position leak more than intended.

## Related Modules In This Domain

- aes_core
- constant_time_compare
- hmac_engine
- secure_boot_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the CMAC Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
