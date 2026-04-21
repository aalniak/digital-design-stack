# Power Domain Controller

## Overview

power_domain_controller sequences enable, isolation, reset, retention, and readiness behavior for a power-managed subsystem. It is the policy owner for domain-level power intent.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

Turning a domain on or off is never just one bit. The order of power, isolation, retention, clocking, and reset matters, and ad hoc sequencing is fragile. power_domain_controller formalizes that order.

## Typical Use Cases

- Bring an accelerator or peripheral domain up and down under software control.
- React to thermal or safety conditions with safe domain shutdown.
- Coordinate state retention and restore during sleep transitions.

## Interfaces and Signal-Level Behavior

- Inputs commonly include power request, wake request, power-good or ready feedback, and software policy bits.
- Outputs drive power enable, isolation, clock gating request, reset hold, and retention control.
- Status reports domain state such as off, ramping, active, quiescing, or faulted.

## Parameters and Configuration Knobs

- SEQUENCE_TIMERS define delays between steps.
- RETENTION_EN indicates support for saved state.
- AUTO_RETRY_EN controls recovery after failed bring-up.
- NUM_WAKE_SOURCES sizes integrated wake qualification if present.
- FAULT_STICKY_EN latches sequencing failures.

## Internal Architecture and Dataflow

The module is usually an FSM with timers and interlock checks. It enforces legal state transitions, waits for acknowledgments such as power-good or lock, and either advances or reports a fault.

## Clocking, Reset, and Timing Assumptions

The controller lives in an always-on or supervisory domain. Feedback signals such as power-good and restore-complete must be meaningful. Reset should establish a conservative safe startup state.

## Latency, Throughput, and Resource Considerations

Power sequencing is slow in cycle terms, so correctness and bounded transition time matter more than throughput. Hardware cost is driven mainly by timers and state tracking.

## Verification Strategy

- Check every legal and illegal state transition path.
- Verify ordering of isolation, reset, retention, and clock controls.
- Inject missing acknowledgments such as absent power-good.
- Exercise repeated enable and disable requests and ensure no wedge state appears.

## Integration Notes and Dependencies

power_domain_controller works closely with retention_controller, wakeup_controller, clock gating, and reset sequencing. It should be the single owner of domain sequencing policy.

## Edge Cases, Failure Modes, and Design Risks

- Incomplete ownership over one step of the sequence is a major architecture hazard.
- Hard-coded delays may not fit every domain equally well.
- Automatic retries can be dangerous if the underlying fault persists.

## Related Modules In This Domain

- retention_controller
- wakeup_controller
- clock_gating_wrapper
- reset_sequencer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Power Domain Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
