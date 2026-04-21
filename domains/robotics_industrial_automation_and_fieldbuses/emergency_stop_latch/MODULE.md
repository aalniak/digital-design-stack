# Emergency Stop Latch

## Overview

Emergency Stop Latch captures emergency-stop events, asserts a persistent stop condition, and requires controlled reset logic before normal operation can resume. It is the retained stop authority for catastrophic or operator-initiated stop events.

## Domain Context

The emergency-stop latch is the immediate stop-memory element that captures an estop request and holds the machine in a safe inhibited condition until an explicit recovery process occurs. In industrial systems it must be simple, deterministic, and impossible to reinterpret casually.

## Problem Solved

An estop signal that merely pulses through logic is not sufficient. The system needs a retained record that a stop occurred, along with a reset policy that ensures human review or deliberate recovery before motion restarts.

## Typical Use Cases

- Latching mushroom-button or safety-relay estop requests.
- Blocking all hazardous machine outputs until a formal reset sequence occurs.
- Providing a clear estop-active status to HMIs and machine sequencers.
- Capturing stop causes during fault investigation or near-miss analysis.

## Interfaces and Signal-Level Behavior

- Inputs include estop request lines, reset command, safety-permit context, and optional auxiliary fault inputs.
- Outputs provide estop_latched, stop_permit_removed, and reset_allowed status.
- Control or configuration is generally minimal but may include diagnostic mirror enables or reset precondition policy.
- Diagnostic outputs may expose source-latched and reset-blocked reasons.

## Parameters and Configuration Knobs

- Number of estop input sources.
- Reset qualification policy and required preconditions.
- Diagnostic hold or source-logging depth.
- Safe-output polarity for downstream consumers.

## Internal Architecture and Dataflow

The module is usually a small but high-priority latch with explicit reset gating and optional source logging. The contract should make clear that reset permission is separate from reset command itself, so software cannot unintentionally clear an estop without the required human or system conditions.

## Clocking, Reset, and Timing Assumptions

Estop inputs may be asynchronous and must be captured reliably. Reset should preserve the latched safe condition until documented preconditions are satisfied. If a safety PLC is the authoritative estop device, this block should be documented as a diagnostic or coordination mirror rather than the primary safety element.

## Latency, Throughput, and Resource Considerations

Latency to assert the latched output should be minimal and deterministic. Logic cost is tiny, but design priority is absolute clarity and robustness rather than feature richness.

## Verification Strategy

- Assert estop under all machine modes and verify immediate persistent latch behavior.
- Check reset blocking until all required preconditions are met.
- Stress repeated estop pulses, bouncing inputs, and simultaneous fault conditions.
- Confirm downstream permits remain removed until latch clear is truly complete.

## Integration Notes and Dependencies

Emergency Stop Latch feeds Safety Interlock Logic, Machine State Sequencer, and motion-disabling paths. It should also surface status to HMIs and maintenance tooling so operators know the exact reason motion remains inhibited.

## Edge Cases, Failure Modes, and Design Risks

- A latch that clears too easily defeats the purpose of an estop.
- If estop status is mirrored inconsistently across subsystems, some axes may appear recoverable while others remain blocked.
- Overcomplicating the latch with too many modes can undermine trust in its behavior.

## Related Modules In This Domain

- safety_interlock_logic
- machine_state_sequencer
- safe_io_voter
- servo_loop_helper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Emergency Stop Latch module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
