# Safety Interlock Logic

## Overview

Safety Interlock Logic evaluates safety-relevant conditions and produces the allow or inhibit outputs that gate hazardous machine functions. It centralizes the combinational and sequential logic behind safe enable decisions.

## Domain Context

Safety interlock logic is the policy layer that decides whether hazardous machine actions are allowed. In industrial automation it combines inputs from guards, drives, estops, safety relays, and subsystem diagnostics into clear permissive or inhibit signals.

## Problem Solved

If every subsystem interprets safety inputs differently, the machine can enter contradictory or unsafe states. A dedicated interlock module makes the safety-permissive rules visible and consistent across motion, actuation, and communications layers.

## Typical Use Cases

- Combining door, light curtain, and drive-ready conditions into a motion permit.
- Blocking hazardous outputs during service access or unexpected safety relay changes.
- Differentiating hard-stop conditions from recoverable operational inhibits.
- Providing clear interlock status to machine diagnostics and HMIs.

## Interfaces and Signal-Level Behavior

- Inputs include guard switches, safety-relay state, drive-enable feedback, reset commands, and machine-mode status.
- Outputs provide interlock_ok, function-specific permits, and inhibit reasons.
- Control registers may configure non-safety diagnostic mirrors, debounce timing, and maintenance-mode rules where allowed.
- Diagnostic outputs expose which prerequisite is currently preventing a permit.

## Parameters and Configuration Knobs

- Number of monitored safety conditions.
- Debounce or stability-check timing for diagnostic copies.
- Separate permit channels for motion, tooling, or process energy.
- Policy options for restart after safety restoration.

## Internal Architecture and Dataflow

The module typically consists of condition qualification, prioritized rule evaluation, and output-permit generation. The contract should clearly separate safety-authoritative signals from convenience diagnostics, especially in systems where certified safety logic exists elsewhere and this module mirrors or augments it.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed already sourced from appropriate safety-rated hardware when required. Reset should force all permits low. If some rules differ by machine mode, that dependency must be explicit so no one assumes a permit means the same thing in every state.

## Latency, Throughput, and Resource Considerations

Logic cost is low, and latency should be short and deterministic because operators expect immediate response when a guard opens or a safety condition clears. Traceability of why a permit is absent is often more valuable than additional complexity.

## Verification Strategy

- Evaluate all safety-condition combinations and confirm permit outputs follow the documented rules.
- Stress transitions during motion or active process states.
- Verify reset and restart-permit behavior after safety restoration.
- Check diagnostic reason outputs for one-hot or otherwise well-defined interpretation.

## Integration Notes and Dependencies

Safety Interlock Logic feeds Machine State Sequencer, motion-permit gating, and operator diagnostics. It should align with Emergency Stop Latch and any external safety PLC or relay so system behavior remains coherent end to end.

## Edge Cases, Failure Modes, and Design Risks

- Mixing safety-authoritative and non-authoritative logic can create dangerous false confidence.
- Ambiguous restart rules can lead to unintended automatic motion after guard closure.
- If permit reasons are not surfaced clearly, operators may bypass safeguards out of frustration.

## Related Modules In This Domain

- emergency_stop_latch
- safe_io_voter
- machine_state_sequencer
- servo_loop_helper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Safety Interlock Logic module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
