# Time-Triggered Scheduler

## Overview

Time-Triggered Scheduler issues scheduled triggers, grants, or enable windows according to a configured periodic timeline. It provides deterministic temporal coordination for communications, sensing, and control activities.

## Domain Context

Time-triggered scheduling is common in aerospace systems where deterministic execution windows and bus access slots matter more than average throughput. In this domain the scheduler aligns subsystem actions to a stable mission or control timeline.

## Problem Solved

Many avionics and spacecraft functions rely on knowing not just what happens, but exactly when. A dedicated scheduler makes slot timing, repetition, and drift-handling explicit rather than embedding them in several independent timer blocks.

## Typical Use Cases

- Scheduling periodic telemetry or telecommand windows.
- Coordinating deterministic sensor sampling and control updates.
- Enforcing time-slotted bus or subsystem access in mission software support hardware.
- Supporting time-triggered system-level validation and replay.

## Interfaces and Signal-Level Behavior

- Inputs include a mission timebase, schedule tables or slot configuration, and optional arm or synchronization commands.
- Outputs provide slot-active signals, trigger pulses, and current-schedule status.
- Control interfaces configure timeline length, slot descriptors, and synchronization or rephase policy.
- Status signals may expose schedule_active, sync_lost, and slot_overrun indicators.

## Parameters and Configuration Knobs

- Number of schedule slots and descriptor width.
- Timebase width and slot timing resolution.
- Periodic versus one-shot schedule support.
- External synchronization and rephase capability.

## Internal Architecture and Dataflow

The scheduler generally contains a timeline counter, slot table or comparators, and trigger generation with optional synchronization correction. The key contract is whether timing is absolute to an external mission clock or relative to local startup, because deterministic coordination depends on that distinction.

## Clocking, Reset, and Timing Assumptions

The module assumes a stable timebase and that scheduled consumers can react within the documented slot semantics. Reset behavior should define whether the schedule restarts from epoch zero or waits for synchronization. If rephasing is supported, the effect on current and next slots should be explicit.

## Latency, Throughput, and Resource Considerations

Area is low, but temporal precision and drift behavior are critical. The main tradeoff is between a flexible slot table and simple deterministic timing with minimal control complexity.

## Verification Strategy

- Verify trigger timing against a software schedule model under nominal and resynchronized operation.
- Stress rollover, schedule updates, and sync-loss conditions.
- Check slot-overlap or overrun reporting where supported.
- Run end-to-end tests with attached telemetry or control consumers to confirm temporal assumptions hold.

## Integration Notes and Dependencies

Time-Triggered Scheduler often coordinates Telemetry Packetizer, Telecommand handling, and health or control loops. It should align with the mission timebase and any external synchronization scheme used by the vehicle.

## Edge Cases, Failure Modes, and Design Risks

- A local-only schedule may appear deterministic in isolation but drift from the mission timeline if external sync assumptions are vague.
- Updating schedules on the fly without clear activation boundaries can create slot ambiguity.
- Consumers may overtrust slot timing unless reaction-latency assumptions are documented alongside the schedule.

## Related Modules In This Domain

- telemetry_packetizer
- telecommand_packetizer
- health_monitor_block
- fault_management_unit

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Time-Triggered Scheduler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
