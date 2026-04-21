# Retention Controller

## Overview

retention_controller manages saving, holding, and restoring state that must survive low-power collapse of a domain. It is the policy bridge between domain power transitions and valid preserved context.

## Domain Context

In the Clocking, Reset, Power, and Timing domain, modules define how the design creates time references, leaves reset, enters and exits low-power modes, and decides whether timing health is still trustworthy. These blocks are small relative to datapath logic, but mistakes in them can destabilize an entire system.

## Problem Solved

Retained state needs explicit ownership. Save timing, restore timing, and validity of retained data are easy to mishandle if hidden in ad hoc logic. retention_controller formalizes that flow.

## Typical Use Cases

- Preserve accelerator or peripheral context across sleep.
- Coordinate save and restore around domain collapse.
- Expose retained-state validity to software or hardware policy.

## Interfaces and Signal-Level Behavior

- Inputs commonly include save request, restore request, domain state, and acknowledgments from retained storage.
- Outputs drive save enable, hold mode, restore trigger, and completion or fault status.
- Control may also interact with reset or isolation timing.

## Parameters and Configuration Knobs

- NUM_BANKS sets retained state groups.
- SAVE_TIMEOUT and RESTORE_TIMEOUT define fault windows.
- AUTO_SAVE_ON_POWERDOWN_EN ties save to power-down entry.
- PARTIAL_RESTORE_EN supports selective resume.
- FAULT_STICKY_EN latches retention errors.

## Internal Architecture and Dataflow

The block is usually an FSM that coordinates save handshakes, tracks whether retained state is valid, and sequences restore before full domain release. Multi-bank variants add per-bank bookkeeping and arbitration.

## Clocking, Reset, and Timing Assumptions

The controller typically resides in an always-on domain and depends on a separate power controller for actual rail control. Reset should define whether retained content starts valid or invalid.

## Latency, Throughput, and Resource Considerations

This is a low-rate control block. The important metrics are added sleep-entry and wake-up latency, plus correctness under interrupted or failed save or restore sequences.

## Verification Strategy

- Check save, collapse, and restore sequences in the nominal path.
- Inject missing acknowledgments and confirm fault handling.
- Verify restored state is considered valid only after the documented point.
- Exercise repeated sleep and wake cycles to catch stale-valid bugs.

## Integration Notes and Dependencies

retention_controller must align closely with power-domain sequencing, clock gating, and reset policy. It should be the single owner of retained-state validity.

## Edge Cases, Failure Modes, and Design Risks

- Treating invalid retained state as valid can corrupt the resumed subsystem.
- Restore that occurs too late can leak illegal transient state.
- Split ownership between retention and power logic creates brittle behavior.

## Related Modules In This Domain

- power_domain_controller
- wakeup_controller
- reset_sequencer
- clock_gating_wrapper

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Retention Controller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
