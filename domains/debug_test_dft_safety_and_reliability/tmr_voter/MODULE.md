# TMR Voter

## Overview

TMR Voter compares or votes among three redundant inputs to produce a majority result and optional disagreement status. It provides the fault-masking decision stage for triple modular redundancy schemes.

## Domain Context

Triple modular redundancy relies on a voter to turn three replicated computations into one tolerated result plus disagreement information. In this domain the voter is the critical point where redundancy becomes actionable fault masking and diagnostic coverage.

## Problem Solved

Replicating logic does not help unless there is a well-defined majority function and a clear way to report disagreement. A dedicated voter ensures majority semantics, tie handling, and diagnostic outputs are explicit and reusable.

## Typical Use Cases

- Masking single-domain faults in redundant control or datapath logic.
- Providing majority-voted outputs in radiation-prone or safety-critical systems.
- Capturing disagreement status for maintenance and reliability trending.
- Supporting localized TMR insertion around critical finite-state machines or controllers.

## Interfaces and Signal-Level Behavior

- Inputs are three redundant value sets plus compare-enable or mask controls.
- Outputs provide majority result, disagreement flags, and optional domain-fault indicators.
- Control interfaces configure masking, latching, and whether disagreement is purely diagnostic or safety-significant.
- Status signals may expose no_majority, disagreement_latched, and voter_active conditions.

## Parameters and Configuration Knobs

- Vote width and number of independent vote channels.
- Per-bit versus grouped vote mode.
- Disagreement reporting granularity.
- Optional latching or count accumulation of disagreement events.

## Internal Architecture and Dataflow

The voter usually contains bitwise or grouped majority logic, disagreement detection, and optional reporting latches or counters. The architectural contract should define what happens when inputs are not strictly binary-equivalent bundles, such as during transients or misalignment, because users need to know whether the voter masks or flags such conditions.

## Clocking, Reset, and Timing Assumptions

The block assumes the three domains are synchronized well enough that their outputs are comparable at the selected decision point. Reset clears diagnostic latches and should not leave stale majority state. If some channels can be masked intentionally, the resulting reduction in coverage should be visible in configuration or status.

## Latency, Throughput, and Resource Considerations

Area grows linearly with vote width and diagnostic richness. Latency is generally minimal. The important tradeoff is between low-cost majority masking and the additional diagnostics needed to know which domain is suspect after repeated disagreements.

## Verification Strategy

- Inject single-domain faults and confirm correct majority output.
- Stress transient and simultaneous multi-domain errors to verify disagreement reporting.
- Check per-bit versus grouped voting semantics.
- Validate integration to safe-state and logging when disagreement persists.

## Integration Notes and Dependencies

TMR Voter often feeds Safe State Controller or fault logging and may coexist with radiation-hardened memory or scrubber infrastructure. It should align with the redundancy plan so software and safety analysis understand what faults are masked versus merely detected.

## Edge Cases, Failure Modes, and Design Risks

- A voter can hide repeated single-domain faults if disagreement reporting is ignored.
- Masking or disabling one leg without surfacing the coverage reduction weakens the reliability story.
- Assuming the voter solves temporal misalignment automatically is a common integration mistake.

## Related Modules In This Domain

- lockstep_comparator
- safe_state_controller
- brownout_fault_interface
- error_logger

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TMR Voter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
