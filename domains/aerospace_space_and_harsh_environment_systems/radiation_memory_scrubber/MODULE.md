# Radiation Memory Scrubber

## Overview

Radiation Memory Scrubber periodically scans protected memory, corrects recoverable upset errors, and reports fault trends relevant to radiation exposure and reliability. It provides proactive memory maintenance for upset-prone environments.

## Domain Context

Radiation-induced upsets are a defining concern in space and other harsh environments, especially for SRAM and stateful memory. In this domain a memory scrubber is not just a convenience feature but part of the core reliability strategy against accumulated SEUs.

## Problem Solved

Single-event upsets can accumulate into uncorrectable faults if corrected words are never refreshed. A dedicated radiation scrubber makes scrub cadence, correction policy, and trend reporting explicit as part of the harsh-environment design strategy.

## Typical Use Cases

- Maintaining SRAM integrity during long-duration space missions.
- Correcting correctable upsets before multi-bit accumulation occurs.
- Reporting upset trends for health and fault management.
- Supporting radiation-tolerant FPGA and processor subsystems with periodic maintenance.

## Interfaces and Signal-Level Behavior

- Inputs include scrub control, target memory selection, ECC status, and optional mission-mode or bandwidth-throttle inputs.
- Outputs provide corrected-error counts, uncorrectable-fault indications, scrub progress, and memory rewrite activity.
- Control interfaces configure scrub cadence, address ranges, and pause or throttle policy.
- Status signals may expose scrub_active, correction_rewrite, and radiation_fault_rate alarms.

## Parameters and Configuration Knobs

- Target memory range and width.
- Scrub interval or bandwidth allocation.
- ECC interface style and correction policy.
- Trend counter or reporting depth.

## Internal Architecture and Dataflow

The scrubber typically sequences background memory reads, observes or applies ECC correction, rewrites corrected content, and accumulates fault statistics. The key contract is how scrub activity coexists with live functional traffic and what counts as a severe radiation condition versus a normal corrected upset.

## Clocking, Reset, and Timing Assumptions

The module assumes memories support safe read and rewrite under the chosen arbitration policy and that ECC is present and configured appropriately. Reset should define whether scrub progress and statistics persist or clear. If some memories are more upset-prone and need different cadence, that configuration model should be explicit.

## Latency, Throughput, and Resource Considerations

Scrub bandwidth competes with functional traffic, so the main tradeoff is between aggressive maintenance and acceptable performance impact. In space use, fault-rate observability is often as valuable as the corrections themselves.

## Verification Strategy

- Inject correctable and uncorrectable upset patterns into representative memory models.
- Stress heavy functional traffic during scrub to verify safe arbitration.
- Check fault trend and count reporting under synthetic upset bursts.
- Validate reset and mission-mode interactions with scrub scheduling.

## Integration Notes and Dependencies

Radiation Memory Scrubber feeds Health Monitor and Fault Management and often shares ECC infrastructure with more general memory wrappers. It should align with mission reliability assumptions and any safe-mode policy tied to upset rates.

## Edge Cases, Failure Modes, and Design Risks

- Too-slow scrub policy can provide little real protection in high-radiation conditions.
- If corrected-upset statistics are not surfaced, operators lose an important health indicator.
- Unsafe arbitration with live memory traffic can create more harm than the scrubber prevents.

## Related Modules In This Domain

- health_monitor_block
- fault_management_unit
- redundant_voter_fabric
- telemetry_packetizer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Radiation Memory Scrubber module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
