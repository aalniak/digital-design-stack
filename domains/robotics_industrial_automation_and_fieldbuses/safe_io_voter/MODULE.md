# Safe I/O Voter

## Overview

Safe I/O Voter combines redundant or multi-channel signals according to a documented voting policy and emits a resulting state plus disagreement diagnostics. It is the decision block for reconciling safety-relevant channel redundancy.

## Domain Context

Safe I/O voting appears in automation systems that use redundant or cross-checked signals to improve fault tolerance and diagnostic coverage. It is especially relevant when several sources must agree before a safety-related input or output is considered trustworthy.

## Problem Solved

Redundant channels are only useful if their agreement policy is explicit. A dedicated voter avoids ad hoc two-out-of-three or pairwise logic scattered across the design and makes disagreement behavior visible to diagnostics and machine control.

## Typical Use Cases

- Voting redundant guard or enable contacts in a safety-adjacent design.
- Cross-checking duplicated sensors before allowing a hazardous function.
- Implementing 2oo2 or 2oo3 style agreement logic for machine diagnostics.
- Providing channel disagreement reporting to maintenance interfaces.

## Interfaces and Signal-Level Behavior

- Inputs are multiple boolean or encoded channel signals plus optional health flags and reset commands.
- Outputs provide voted state, disagreement status, and possibly degraded-mode indication.
- Control registers configure the voting policy, persistence thresholds, and diagnostic masks where allowed.
- Diagnostic outputs expose per-channel mismatch or stuck-signal indicators.

## Parameters and Configuration Knobs

- Number of channels and supported voting modes.
- Persistence or debounce depth for declaring disagreement.
- Diagnostic granularity and latched versus live error behavior.
- Output-safe-state policy when voting fails.

## Internal Architecture and Dataflow

The voter usually contains channel qualification, agreement logic, and disagreement diagnostics. The contract should state what happens on disagreement with no ambiguity, because some systems prefer fail-safe inhibit while others allow degraded operation only for clearly non-hazardous functions.

## Clocking, Reset, and Timing Assumptions

Channels are assumed to represent the same physical intent and to be synchronized or slow enough that transient skew is manageable. Reset should place the module in the documented safe interpretation. If the block is not safety-certified, that limitation should be explicit in the documentation.

## Latency, Throughput, and Resource Considerations

Logic cost is low. Timely detection of disagreement matters more than speed. The diagnostic path should be as clear and deterministic as the voted output itself.

## Verification Strategy

- Test all agreement and disagreement combinations for each supported voting mode.
- Stress skewed transitions and stuck-at faults.
- Verify safe-state behavior when channel health degrades.
- Check latched diagnostic behavior across reset and recovery.

## Integration Notes and Dependencies

Safe I/O Voter often feeds Safety Interlock Logic and Machine State Sequencer while surfacing maintenance diagnostics. It should align with the machine safety concept on whether disagreement causes a hard stop, inhibited restart, or diagnostic-only alert.

## Edge Cases, Failure Modes, and Design Risks

- A voter that defaults to permissive output on disagreement can create a serious hazard.
- If diagnostic and voted outputs disagree semantically, troubleshooting becomes error-prone.
- Unclear certification status may cause teams to overtrust a non-safety implementation.

## Related Modules In This Domain

- safety_interlock_logic
- emergency_stop_latch
- machine_state_sequencer
- timestamp_synchronizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Safe I/O Voter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
