# Redundant Voter Fabric

## Overview

Redundant Voter Fabric applies majority or agreement voting across replicated functional domains and produces voted outputs plus disagreement diagnostics. It provides system-level redundancy consolidation for harsh-environment and high-reliability designs.

## Domain Context

A redundant voter fabric generalizes majority voting across several replicated subsystems or signal groups rather than a single narrow TMR cell. In this domain it is the structural glue that turns broad redundancy into a coherent output and diagnostic scheme.

## Problem Solved

Redundant modules need consistent majority logic, disagreement reporting, and grouping across many signals. A dedicated fabric keeps that policy centralized and scalable rather than scattering small voters with inconsistent semantics across the design.

## Typical Use Cases

- Voting triplicated control and data outputs in a radiation-tolerant subsystem.
- Providing majority-decided state to downstream mission logic.
- Capturing disagreement patterns for maintenance and health telemetry.
- Supporting structured redundant-design integration in FPGA or ASIC avionics logic.

## Interfaces and Signal-Level Behavior

- Inputs are replicated signal groups or bus bundles plus compare-enable or mask controls.
- Outputs provide voted results, disagreement flags, and optional per-domain suspect indicators.
- Control interfaces configure vote groups, diagnostic mode, and any degraded-operation policies.
- Status signals may expose no_majority, disagreement_latched, and voted_output_valid indications.

## Parameters and Configuration Knobs

- Number of replicated domains and signal-group width.
- Per-bit versus grouped vote semantics.
- Diagnostic detail level and latching mode.
- Optional degraded dual-channel or masked mode support.

## Internal Architecture and Dataflow

The fabric generally instantiates or orchestrates majority logic over many signal groups, aggregates diagnostics, and may classify persistent disagreements. The key contract is whether the fabric is purely combinational voting or includes temporal filtering and domain-health interpretation, because those additions change both latency and system-level meaning.

## Clocking, Reset, and Timing Assumptions

The block assumes replicated domains are synchronized well enough to be compared meaningfully. Reset clears diagnostic latches and any temporal history. If degraded operation with fewer healthy domains is allowed, that policy and resulting coverage reduction must be explicit.

## Latency, Throughput, and Resource Considerations

Area grows with the width and number of voted groups. Latency is low, though temporal filtering can increase it. The main tradeoff is between rich disagreement diagnostics and a lean low-latency majority path.

## Verification Strategy

- Inject single-domain faults and verify voted outputs remain correct.
- Stress several simultaneous disagreement patterns and no-majority conditions if possible.
- Check diagnostic aggregation and latching behavior.
- Validate system-level interaction with fault management under persistent domain mismatch.

## Integration Notes and Dependencies

Redundant Voter Fabric often feeds mission control logic, Health Monitor, and Fault Management and may be paired with Radiation Memory Scrubber and time-triggered deterministic control. It should align with the redundancy architecture assumptions used in the system reliability case.

## Edge Cases, Failure Modes, and Design Risks

- A voter fabric can hide repeated single-domain faults if disagreement telemetry is ignored.
- If grouped vote semantics are vague, some signals may be masked while others should really trip the system.
- Degraded-operation support can be dangerous if coverage loss is not surfaced clearly.

## Related Modules In This Domain

- fault_management_unit
- health_monitor_block
- radiation_memory_scrubber
- time_triggered_scheduler

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Redundant Voter Fabric module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
