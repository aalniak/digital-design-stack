# Carrier Phase Engine

## Overview

Carrier Phase Engine derives continuous or epoch-referenced carrier-phase measurements from tracked satellite channels and packages them with quality indicators. It turns PLL-aligned carrier state into a precision-grade navigation observable.

## Domain Context

Carrier-phase extraction targets the fine phase observable needed for high-precision GNSS techniques such as RTK, PPP, and precise velocity estimation. It sits downstream of stable carrier tracking and exposes a more delicate but much more precise measurement than code-based pseudorange alone.

## Problem Solved

Carrier phase offers far finer resolution than code phase, but only if cycle continuity, sign conventions, and lock quality are handled rigorously. A dedicated engine is needed so these subtleties are not buried inside generic tracking-loop telemetry.

## Typical Use Cases

- Producing carrier-phase observables for RTK or PPP pipelines.
- Estimating precise velocity through carrier dynamics.
- Monitoring cycle slips and phase continuity during weak-signal tracking.
- Recording raw precision observables for post-processed navigation analysis.

## Interfaces and Signal-Level Behavior

- Inputs include carrier NCO or PLL state, prompt correlations, and channel timing markers.
- Outputs provide carrier-phase measurement, measurement epoch, lock quality, and cycle-slip indicators.
- Controls configure measurement cadence, ambiguity-handling policy, and reporting format.
- Diagnostic outputs may expose residual phase error, lock counters, and unwrap state.

## Parameters and Configuration Knobs

- Phase accumulator width and output precision.
- Measurement cadence and accumulation policy.
- Cycle-slip detection thresholds and continuity tracking depth.
- Support for fractional-cycle plus integer-cycle reporting formats.

## Internal Architecture and Dataflow

The engine usually combines phase-state capture, unwrapping or continuity management, quality assessment, and measurement formatting. The contract should define whether outputs are instantaneous wrapped phase, continuous accumulated phase, or a split ambiguity representation, because downstream precision solvers depend on that exact meaning.

## Clocking, Reset, and Timing Assumptions

The block assumes carrier tracking is stable enough that phase continuity is meaningful over the measurement interval. Reset breaks continuity explicitly and should surface that break in the output metadata. If aiding or handoff from FLL to PLL occurs, the continuity policy must be documented.

## Latency, Throughput, and Resource Considerations

Computation is light, but numerical precision and continuity bookkeeping are critical. Throughput follows the measurement cadence rather than the sample rate, while correctness hinges on never silently losing a cycle in the reported history.

## Verification Strategy

- Replay known carrier phase trajectories and confirm exact wrapped and unwrapped behavior.
- Exercise cycle-slip events and verify detection plus continuity reset semantics.
- Check measurement epoch alignment against pseudorange outputs.
- Compare extracted phase against a high-precision software receiver reference.

## Integration Notes and Dependencies

Carrier Phase Engine follows Carrier Tracking PLL and feeds precision navigation solvers or Kalman Fusion Engine. It should align with Pseudorange Engine on epoch definition so combined code and phase measurements are internally consistent.

## Edge Cases, Failure Modes, and Design Risks

- A hidden cycle-slip or ambiguity reset can invalidate high-precision solutions badly.
- If phase output meaning is underspecified, downstream solvers may apply the wrong ambiguity model.
- Measurement epochs that differ subtly from pseudorange epochs complicate fusion and debugging.

## Related Modules In This Domain

- carrier_tracking_pll
- pseudorange_engine
- frequency_locked_loop
- kalman_fusion_engine

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Carrier Phase Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
