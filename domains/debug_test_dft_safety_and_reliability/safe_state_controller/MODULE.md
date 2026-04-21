# Safe State Controller

## Overview

Safe State Controller evaluates severe fault inputs and drives the system into a predefined safe operating condition or shutdown posture. It provides centralized fault-response coordination for reliability and safety architectures.

## Domain Context

A safe-state controller is the escalation block that determines how a design reacts when faults reach the threshold of unacceptable risk. In this domain it coordinates quiescing outputs, disabling hazardous actions, and presenting a stable fault state that the wider system can reason about.

## Problem Solved

Many subsystems can detect problems, but without a dedicated response coordinator they may react inconsistently or too late. A safe-state controller centralizes the policy for how the design behaves when continuing normal operation is no longer acceptable.

## Typical Use Cases

- Disabling hazardous outputs when critical faults occur.
- Coordinating orderly degradation or shutdown across several functional domains.
- Providing a single safe-mode status to software and external supervision.
- Supporting safety cases that require deterministic system reaction to monitored faults.

## Interfaces and Signal-Level Behavior

- Inputs are severe-fault indications, quality or lifecycle qualifiers, acknowledge or clear commands, and optional power-fault status.
- Outputs provide safe_mode_active, output_inhibit, reset_request, and domain-level quiesce signals.
- Control interfaces configure fault-to-action mapping, latching policy, and recovery prerequisites.
- Status signals may expose safe_state_cause, recovery_blocked, and active_quiesce_bitmap.

## Parameters and Configuration Knobs

- Number of fault inputs and action outputs.
- Latch versus recoverable-safe-state policy.
- Per-domain response mapping.
- Optional staged escalation timing.

## Internal Architecture and Dataflow

The controller usually contains fault-priority logic, state sequencing, output action mapping, and recovery gating. The crucial contract is whether the safe state is simply a latched status or an active sequenced behavior with several phases, because downstream domains need to know what timing guarantees they can rely on during fault entry.

## Clocking, Reset, and Timing Assumptions

The block assumes input fault indications are trustworthy and synchronized or safely captured. Reset behavior must be documented carefully, especially if some faults are intended to persist across soft reset. If recovery requires external supervision or power cycling, that policy should be explicit.

## Latency, Throughput, and Resource Considerations

Reaction latency is critical, especially for hazardous outputs. Area is modest but correctness is paramount. The tradeoff is between a simple immediate shutoff policy and a richer sequenced safe state that preserves more diagnosability or graceful shutdown behavior.

## Verification Strategy

- Inject each critical fault and verify the expected safe-state action and latency.
- Stress simultaneous faults and recovery or clear attempts.
- Check domain-specific quiesce outputs and their persistence across reset classes.
- Verify diagnostic cause reporting remains coherent when several faults are active together.

## Integration Notes and Dependencies

Safe State Controller consumes Brownout, Assertion, ECC, Fault Injector, and voter outputs and often feeds output-disable paths plus Error Logger and Event Recorder. It should align with the product safety concept so hardware, software, and external safety supervision agree on what safe mode means.

## Edge Cases, Failure Modes, and Design Risks

- A safe-state controller that is not the single source of truth can race or conflict with local subsystem reactions.
- Recovery policy that is too permissive may restart into an unsafe or poorly diagnosed condition.
- If cause reporting is vague, postmortem analysis becomes much harder even when the safe action itself worked.

## Related Modules In This Domain

- brownout_fault_interface
- error_logger
- tmr_voter
- assertion_monitor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Safe State Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
