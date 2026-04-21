# LBIST Controller

## Overview

LBIST Controller sequences logic built-in self-test sessions, coordinating pattern generation, scan or observation paths, and signature collection. It provides the logic self-test control layer for manufacturing and in-field diagnostic use.

## Domain Context

Logic BIST applies pseudo-random or structured self-test patterns to combinational and sequential logic rather than to memories. In this domain it is the on-chip orchestration block that manages pattern generation, signature capture, and test-session control for logic health checks.

## Problem Solved

Logic self-test requires tightly coordinated control over stimulus generation, observation compaction, and pass or fail interpretation. A dedicated controller makes those steps explicit so LBIST behavior is reproducible and auditable rather than implied by separate pattern and MISR blocks.

## Typical Use Cases

- Running logic self-test during manufacturing or safety startup diagnostics.
- Providing periodic in-field latent fault detection in safety-related systems.
- Coordinating pseudo-random pattern application and signature analysis.
- Isolating logic-test sequencing from memory-test or scan-control policy.

## Interfaces and Signal-Level Behavior

- Inputs include start_test, pattern-count configuration, selected-domain controls, and expected signature context.
- Outputs provide test_done, pass_fail, signature value or status, and active-test indicators.
- Control interfaces configure pattern depth, test partitions, and capture policy.
- Status signals may expose signature_mismatch, domain_busy, and invalid_test_configuration conditions.

## Parameters and Configuration Knobs

- Number of supported LBIST partitions or domains.
- Maximum pattern count and signature width.
- Expected-signature storage mode.
- Support for pseudo-random only versus mixed deterministic top-up patterns if present.

## Internal Architecture and Dataflow

The controller usually sequences PRBS pattern enable, capture phases, signature compaction windows, and result comparison across one or more logic domains. The architectural contract should define what exactly is considered a passing signature and how deterministic the test session is under fixed seeds and partitioning.

## Clocking, Reset, and Timing Assumptions

The block assumes logic under test can be driven into a test-compatible state and that clocks and resets are controlled appropriately during LBIST. Reset should abort active LBIST safely and restore functional ownership. If signatures depend on lifecycle-specific seeds or masks, those dependencies should be documented explicitly.

## Latency, Throughput, and Resource Considerations

LBIST runtime is controlled by pattern count and partition size. Area cost is modest beyond the distributed test logic. The main tradeoff is between test coverage and acceptable execution time or functional disruption in field use.

## Verification Strategy

- Verify sequencing of pattern application, capture, and signature compare on representative logic models.
- Check deterministic signature behavior under fixed seeds and partition selection.
- Stress abort and reset behavior during active LBIST.
- Validate pass_fail interpretation when expected signatures are missing or mismatched.

## Integration Notes and Dependencies

LBIST Controller works with PRBS generators, scan infrastructure, signature compactors, and system safety policy. It should align with startup diagnostic requirements and not be confused with MBIST coverage, which addresses a different fault class.

## Edge Cases, Failure Modes, and Design Risks

- Pseudo-random coverage can be overestimated if the actual logic partitioning is not well understood.
- If expected signatures are stale or tied to the wrong configuration, good silicon may fail or bad silicon may pass.
- Running LBIST at the wrong time can disrupt functional state or violate uptime requirements.

## Related Modules In This Domain

- prbs_generator_checker
- scan_controller
- mbist_controller
- error_logger

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the LBIST Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
