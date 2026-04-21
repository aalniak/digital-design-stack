# OTP/eFuse Controller

## Overview

OTP/eFuse Controller provides controlled read, program, protection, and status access for one-time programmable security state. It is the hardware gateway to irreversible device personalization and lifecycle anchoring.

## Domain Context

OTP and eFuse control logic governs one-time programmable state such as root keys, lifecycle bits, device configuration locks, and anti-rollback anchors. In the security domain this controller is both a storage primitive and a policy surface, because who may read or burn which words matters as much as electrical correctness.

## Problem Solved

Root secrets, lifecycle state, and permanent lock bits cannot be treated like ordinary registers. A dedicated OTP controller is needed so timing, programming voltage control, permission checks, and irreversible state transitions are all explicit and reviewable.

## Typical Use Cases

- Reading fused root keys, lifecycle state, and permanent configuration locks during boot.
- Programming manufacturing personalization data under tightly controlled conditions.
- Anchoring anti-rollback counters and permanent security enables.
- Exposing audited, restricted visibility into immutable device identity or policy state.

## Interfaces and Signal-Level Behavior

- Inputs typically include read or program command, address or row selector, data payload for programming, and privilege or lifecycle qualification.
- Outputs provide read data, program-complete, busy, and program-failure or lock-status indicators.
- Control interfaces configure test-manufacturing access, read masking, and irreversible lock or finalize operations.
- Status signals often expose margin-check results, program-voltage fault, and access-denied conditions.

## Parameters and Configuration Knobs

- Row width, address depth, and read masking granularity.
- Read-only versus program-capable lifecycle modes.
- Support for shadow registers, redundancy, or ECC around OTP rows.
- Whether secret rows are readable directly, only internally routable, or entirely opaque to software.

## Internal Architecture and Dataflow

The controller usually contains command sequencing, OTP macro interface timing, permission checks, shadowing or caching of stable fields, and optional redundancy or error detection. The architectural contract should distinguish clearly between rows that are software-readable, rows that are consumer-routable only through secure paths, and rows that are never exposed at all.

## Clocking, Reset, and Timing Assumptions

This controller assumes the OTP macro or eFuse array is physically protected enough that programming remains a privileged manufacturing or field-service act. Reset should not modify persistent state but may invalidate temporary shadow caches until reread. If program operations require special voltage or timing conditions, the documentation should state who guarantees those conditions and how failures are reported.

## Latency, Throughput, and Resource Considerations

Read latency is typically modest, while program operations are slow and infrequent. Resource cost comes from sequencing, redundancy support, and access control rather than datapath width. Reliability and irreversible-state correctness matter much more than transaction rate.

## Verification Strategy

- Verify allowed and denied read and program operations across lifecycle states and address classes.
- Stress partially failed programming and confirm safe fault reporting rather than ambiguous state exposure.
- Check that secret rows cannot be observed through unintended debug, shadow, or bus paths.
- Validate lock or finalize operations so one-way transitions are honored after reset and power cycle.

## Integration Notes and Dependencies

OTP/eFuse Controller feeds Key Ladder, Secure Boot Block, Anti-Rollback Counter, and lifecycle policy logic. It should align with manufacturing tooling, tamper policy, and debug restrictions so the same permanent bits are interpreted consistently across the full secure lifecycle.

## Edge Cases, Failure Modes, and Design Risks

- A single mistakenly software-readable secret row can compromise the entire hardware root of trust.
- Programming-policy mistakes are often irreversible and may brick or permanently weaken devices.
- Cached shadow values that outlive lifecycle changes or tamper events can create stale-policy vulnerabilities.

## Related Modules In This Domain

- key_ladder
- anti_rollback_counter
- secure_boot_block
- tamper_monitor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the OTP/eFuse Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
