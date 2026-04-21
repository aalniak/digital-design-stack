# Soft Start Controller

## Overview

Soft Start Controller sequences controlled ramp-up and, in some designs, ramp-down of actuation commands so the system enters operation smoothly and safely. It provides managed bring-up behavior around otherwise aggressive control loops.

## Domain Context

Soft start is the supervisory ramp-up logic that prevents abrupt electrical and mechanical stress during enable. In motor drives and digital power systems it governs how duty, current, voltage, or speed commands rise from zero into normal closed-loop operation.

## Problem Solved

Instantly applying full loop authority at enable can cause inrush current, torque shock, overshoot, or false protection trips. A dedicated soft-start block creates a documented state machine for staged enable and reference ramping.

## Typical Use Cases

- Ramping motor current or speed demand during startup.
- Sequencing converter duty or reference rise to avoid inrush.
- Coordinating sensor validation and loop handoff before closed-loop actuation.
- Providing controlled restart behavior after recoverable faults.

## Interfaces and Signal-Level Behavior

- Inputs include enable requests, fault-clear status, feedback-valid signals, and commanded targets.
- Outputs provide ramped references, startup-state status, and permissive signals for downstream loops.
- Control registers configure ramp rates, dwell times, precharge or alignment phases, and restart policy.
- Diagnostic outputs may expose current startup phase, timeout conditions, and blocked-enable reasons.

## Parameters and Configuration Knobs

- Ramp-rate precision and maximum startup duration.
- Number of startup phases or sequencer states.
- Alignment or precharge timing support.
- Restart policy after a fault or disable event.

## Internal Architecture and Dataflow

The controller typically contains a state machine, rate limiters, permissive checks, and handoff logic into normal control. The key contract is when control authority transfers from startup sequencing to the steady-state loop and what conditions must be met before that handoff is considered safe.

## Clocking, Reset, and Timing Assumptions

Soft start assumes downstream loops and protection paths honor the ramped references or enable permissions it generates. Reset returns the module to a non-actuating idle state. If the startup depends on valid position or current feedback, those prerequisites should be explicit.

## Latency, Throughput, and Resource Considerations

Resource use is low. Latency is not critical in the arithmetic sense, but deterministic state progression matters for reproducible startup behavior. The main performance measure is a safe, repeatable transition into normal operating mode without nuisance faults.

## Verification Strategy

- Replay enable, disable, and fault-recovery sequences to verify state progression and ramp shape.
- Check startup blocking when required feedback or preconditions are missing.
- Stress restart-after-fault behavior to ensure no unsafe bypass of alignment or precharge steps.
- Verify handoff to steady-state control does not introduce a command discontinuity.

## Integration Notes and Dependencies

Soft Start Controller coordinates with Speed Loop Controller, Overcurrent Shutdown, and sensor-valid feedback sources such as Hall or resolver paths. It should also align with any power-stage precharge or external interlock logic.

## Edge Cases, Failure Modes, and Design Risks

- A soft-start sequence that hands off too early can trigger immediate current or speed overshoot.
- Ignoring sensor-valid prerequisites may cause unstable startup on sensor-dependent drives.
- If restart policy is too permissive, repeated fault cycling can stress hardware severely.

## Related Modules In This Domain

- speed_loop_controller
- overcurrent_shutdown
- hall_sensor_decoder
- resolver_interface

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Soft Start Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
