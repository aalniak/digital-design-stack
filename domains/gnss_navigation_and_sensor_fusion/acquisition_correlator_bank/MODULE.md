# Acquisition Correlator Bank

## Overview

Acquisition Correlator Bank computes many code-phase and Doppler correlations in parallel or through time-multiplexing to identify candidate satellite locks. It converts incoming baseband samples into acquisition peaks with associated hypothesis metadata.

## Domain Context

Acquisition is the search phase of a GNSS receiver, where the system explores code delay and Doppler hypotheses to discover visible satellites. The correlator bank is the domain module that turns wide search space into structured detection metrics.

## Problem Solved

GNSS signal discovery requires searching a large two-dimensional space of code offset and Doppler. Implementing that search piecemeal across custom logic makes it hard to reason about sensitivity, search coverage, and hypothesis ranking. A dedicated correlator bank centralizes that behavior.

## Typical Use Cases

- Searching for visible satellites during cold start.
- Reacquiring satellites after signal loss or duty-cycled operation.
- Evaluating candidate Doppler bins and code phases for multiple PRNs in parallel.
- Supporting laboratory sensitivity studies across different coherent integration times.

## Interfaces and Signal-Level Behavior

- Inputs are incoming complex baseband samples plus control selections for PRN, Doppler search range, and integration policy.
- Outputs typically include correlation magnitudes, best-hypothesis reports, and candidate-detected events with code phase and Doppler estimates.
- Control paths configure coherent and noncoherent accumulation length, search scheduling, and detection thresholds.
- Status signals may indicate search_active, candidate_ready, and completion or overflow conditions.

## Parameters and Configuration Knobs

- Number of parallel correlator lanes or time-multiplex factor.
- Supported Doppler bin spacing, code-phase resolution, and integration lengths.
- Input sample width, accumulator width, and detection metric format.
- Maximum number of acquisition candidates retained per search pass.

## Internal Architecture and Dataflow

The block generally combines PRN generation, carrier wipeoff hypotheses, correlation accumulation, magnitude evaluation, and peak selection. The architectural contract should state how hypotheses are scheduled and how partial search coverage is reported so software can reason about search completeness.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed sampled at a known rate and preconditioned enough that the chosen search grid is meaningful. Reset clears partial accumulations and candidate memory. If searches are time-multiplexed, the design should document latency and revisit interval per hypothesis.

## Latency, Throughput, and Resource Considerations

Acquisition cost is substantial because the search space is large. Resource use scales with parallel hypotheses, while latency scales with integration length and scheduling. Deterministic reporting of the best candidates matters more than brute-force throughput alone.

## Verification Strategy

- Inject synthetic GNSS signals with known PRN, code phase, and Doppler and confirm correct candidate ranking.
- Stress weak-signal cases near the detection threshold to evaluate metric stability.
- Verify search coverage and completion signaling when hypotheses are time-multiplexed.
- Compare peak metrics against a floating-point or software acquisition reference over representative scenarios.

## Integration Notes and Dependencies

Acquisition Correlator Bank consumes PRN Generator output and seeds Carrier Tracking PLL and Code Tracking DLL once a candidate is accepted. It also interacts with host search management that decides which constellations and Doppler ranges to explore next.

## Edge Cases, Failure Modes, and Design Risks

- A search grid that is too coarse can miss valid satellites while still appearing functional.
- Poorly documented detection metrics can make candidate thresholds hard to tune across signal conditions.
- If partial search completion is mistaken for full coverage, cold-start performance will be misleadingly optimistic.

## Related Modules In This Domain

- prn_generator
- carrier_tracking_pll
- code_tracking_dll
- frequency_locked_loop

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Acquisition Correlator Bank module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
