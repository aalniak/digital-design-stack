# Fault Management Unit

## Overview

Fault Management Unit receives fault and health information from monitored subsystems and drives configured recovery, reconfiguration, or safe-mode actions. It provides centralized fault response coordination for harsh-environment systems.

## Domain Context

Fault management is the mission-level decision layer that decides what a spacecraft or avionics subsystem should do when anomalies occur. In this domain it goes beyond raw detection and defines escalation, isolation, recovery, and reporting policy.

## Problem Solved

Aerospace systems cannot treat every fault the same way, and local recovery alone is often insufficient. A dedicated fault-management unit makes escalation, retries, isolation, and safe-mode policy explicit and consistent.

## Typical Use Cases

- Escalating communication, memory, or timing faults into mission-safe responses.
- Coordinating retries, isolation, or subsystem reset actions after detected anomalies.
- Driving safe-mode or degraded-mode transitions in spacecraft logic.
- Providing a single hardware-visible point for fault policy and reporting.

## Interfaces and Signal-Level Behavior

- Inputs are subsystem fault indications, health summaries, command acknowledgements, and mission-mode qualifiers.
- Outputs provide recovery actions, reset requests, safe-mode triggers, and fault-summary status.
- Control interfaces configure fault classes, escalation thresholds, retry counts, and action mapping.
- Status signals may expose current_fault_state, recovery_in_progress, and latched_major_fault indications.

## Parameters and Configuration Knobs

- Number of fault sources and action outputs.
- Retry and escalation threshold widths.
- Safe-mode and degraded-mode mapping options.
- Persistent fault-log or summary retention support.

## Internal Architecture and Dataflow

The unit typically contains fault classification, escalation state machines, retry counters, and action routing to resets, isolation controls, or mission mode changes. The key contract is whether it owns final authority over safe-mode entry or merely recommends action to software, because that distinction shapes the whole system safety concept.

## Clocking, Reset, and Timing Assumptions

The module assumes incoming fault and health signals are meaningful and time-aligned enough for policy decisions. Reset behavior should clearly define which latched faults survive and whether recovery state is abandoned or preserved. If software can override or inhibit hardware fault actions, that capability should be documented very carefully.

## Latency, Throughput, and Resource Considerations

Fault-response latency matters, but determinism and policy clarity matter more than speed alone. The main tradeoff is between rich nuanced fault policy and a simpler response model that is easier to verify and certify.

## Verification Strategy

- Exercise each fault class through normal, retry, and escalated paths.
- Stress simultaneous faults and conflicting action mappings.
- Check latched-major-fault behavior across resets and recovery attempts.
- Run integrated mission-mode simulations to verify that outputs drive the intended system response.

## Integration Notes and Dependencies

Fault Management Unit consumes Health Monitor, communication, and memory-protection signals and interacts with telemetry and scheduler logic. It should align with mission fault trees and operational concepts rather than functioning as an isolated local safety block.

## Edge Cases, Failure Modes, and Design Risks

- A fault manager that is too aggressive can push the system into safe mode unnecessarily.
- A fault manager that is too permissive can allow cascading subsystem degradation.
- Policy distributed ambiguously between hardware and software makes failures hard to diagnose and certify.

## Related Modules In This Domain

- health_monitor_block
- telemetry_packetizer
- time_triggered_scheduler
- radiation_memory_scrubber

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Fault Management Unit module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
