# Lockstep Comparator

## Overview

Lockstep Comparator compares state or output streams from redundant lockstep domains and reports divergence according to configured timing and masking rules. It provides mismatch detection for redundant execution architectures.

## Domain Context

Lockstep comparison is a fault-detection technique used when redundant processing elements execute the same work and a mismatch indicates latent logic or state corruption. In this domain it is the decision block that turns dual execution into a concrete safety signal.

## Problem Solved

Redundant execution only improves reliability if there is a clear, deterministic way to compare the redundant domains and decide when they have diverged. A dedicated comparator makes comparison timing, scope, and tolerated differences explicit.

## Typical Use Cases

- Comparing dual-core or dual-pipeline lockstep execution for safety applications.
- Detecting divergence between redundant state machines or processors.
- Providing a hardware mismatch event to safe-state logic.
- Supporting safety-validation campaigns of redundant execution architectures.

## Interfaces and Signal-Level Behavior

- Inputs are corresponding state or output vectors from two lockstep domains plus compare-enable and timing-alignment controls.
- Outputs provide mismatch_detected, mismatch_detail or source ID, and status for compare-active windows.
- Control interfaces configure compare masks, tolerated skew, and clear or latching behavior.
- Status signals may expose compare_suppressed, mismatch_latched, and alignment_error conditions.

## Parameters and Configuration Knobs

- Compare width and number of compare groups.
- Allowed cycle skew or alignment depth.
- Masking and don-t-care bit support.
- Pulse versus latched mismatch reporting mode.

## Internal Architecture and Dataflow

The comparator generally contains alignment buffering, bitwise comparison or masked equivalence checking, and reporting or latch logic. The key contract is whether compared domains are expected to match cycle-for-cycle or only at defined checkpoints, because safety interpretation depends directly on that expectation.

## Clocking, Reset, and Timing Assumptions

The block assumes the two compared domains are meaningfully equivalent and any intentional timing skew is configured correctly. Reset clears mismatch history and alignment state. If some state bits are intentionally excluded or delayed, those exclusions must be documented clearly to avoid false confidence in lockstep coverage.

## Latency, Throughput, and Resource Considerations

Area scales with compare width and alignment buffering. Latency is low, typically one or a few cycles beyond alignment depth. The important tradeoff is between broad comparison coverage and the cost of buffering, masking, or tolerating expected microarchitectural differences.

## Verification Strategy

- Verify no false mismatches on known equivalent lockstep traces.
- Inject controlled divergence and check mismatch timing and latching behavior.
- Stress alignment skew and compare-mask edge cases.
- Validate safe-state integration using realistic fault scenarios rather than only synthetic bit flips.

## Integration Notes and Dependencies

Lockstep Comparator commonly feeds Safe State Controller and Error Logger and sits near redundant cores, pipelines, or controllers. It should align with the redundancy architecture documentation so compare scope matches what the safety case actually assumes.

## Edge Cases, Failure Modes, and Design Risks

- Masking too much state can make lockstep look effective while missing meaningful divergence.
- Compare timing mismatches are a common source of nuisance trips if expected skew is not handled carefully.
- A comparator that only checks outputs may miss deep internal divergence until too late for safe recovery.

## Related Modules In This Domain

- tmr_voter
- safe_state_controller
- error_logger
- fault_injector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Lockstep Comparator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
