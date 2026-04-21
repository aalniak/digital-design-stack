# Constant-Time Compare

## Overview

Constant-Time Compare evaluates equality between two fixed-width values while consuming a deterministic amount of work independent of where the first mismatch occurs. It provides a reusable non-early-exit comparison primitive for security-sensitive verification paths.

## Domain Context

Constant-time comparison is a small but important defensive primitive in secure hardware. It exists to compare tags, hashes, keys, or policy tokens without leaking mismatch position or early-termination timing that could otherwise be observed through software-visible latency or side channels.

## Problem Solved

Naive equality logic or microcoded comparison helpers may reveal how many leading bytes matched before failure, especially when wrapped in software-visible control flow. A dedicated compare block lets integrators state clearly that verification outcomes are not supposed to vary in timing with mismatch position.

## Typical Use Cases

- Comparing authentication tags in AES-GCM, CMAC, or HMAC verification.
- Checking expected versus measured hash values during secure boot.
- Verifying challenge-response tokens or wrapped-key checksums.
- Providing a hardened equality primitive inside composite security state machines.

## Interfaces and Signal-Level Behavior

- Inputs are two values of equal width plus start or valid markers and optional context metadata.
- Outputs provide equal or not_equal status along with done or ready signaling that is independent of mismatch position.
- Control interfaces are usually minimal but may include width mode selection or sticky-fault enable for width mismatches.
- Status outputs may expose busy, compare_done, and invalid_width or malformed-request conditions.

## Parameters and Configuration Knobs

- Supported compare width or maximum operand width.
- Pure combinational versus registered fixed-latency implementation.
- Single-shot versus streaming block-compare mode.
- Optional mismatch-mask debug path for secure lab-only builds if permitted at all.

## Internal Architecture and Dataflow

Typical designs XOR all compared words, OR-reduce the mismatch vector, and present the boolean result only after a fixed-latency completion point. The critical architectural rule is that no internal early-exit path, truncated bus observation, or variable-cycle status update should reveal where the mismatch occurred.

## Clocking, Reset, and Timing Assumptions

This block assumes both operands are already authorized to be present in the same trust domain. Reset simply clears transient control state and should not preserve compared secrets. If debug or observability hooks exist, their availability must be tightly lifecycle-gated or omitted from production altogether.

## Latency, Throughput, and Resource Considerations

Area and latency cost are low, though very wide operands may need pipelining. The main performance metric is determinism, not speed. Even if a faster early-exit compare were possible, the purpose of this module is to reject that optimization in security-sensitive contexts.

## Verification Strategy

- Measure or inspect latency to confirm it is identical for equal values and for mismatches at every bit position.
- Check correctness across all supported widths, including all-zero and all-one edge cases.
- Stress back-to-back operations and reset interaction so no stale mismatch information survives.
- If lifecycle-gated debug visibility exists, verify it is disabled or blocked in production mode.

## Integration Notes and Dependencies

Constant-Time Compare is typically called by GCM, CMAC, HMAC, and Secure Boot Block verification logic. It should be used wherever a verification boolean is security significant and where software would otherwise be tempted to compare large values manually.

## Edge Cases, Failure Modes, and Design Risks

- A constant-time compare used inside an otherwise variable-latency control path can still leak indirectly.
- Adding debug visibility of mismatch position defeats the point of the primitive unless very tightly controlled.
- Treating this module as universally necessary can add overhead where simple nonsecret compares would suffice, so trust-boundary intent should stay clear.

## Related Modules In This Domain

- aes_gcm_engine
- cmac_engine
- hmac_engine
- secure_boot_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Constant-Time Compare module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
