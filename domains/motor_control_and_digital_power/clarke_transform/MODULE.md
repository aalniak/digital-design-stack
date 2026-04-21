# Clarke Transform

## Overview

Clarke Transform maps three-phase or two-phase current or voltage measurements into alpha-beta stationary-frame components. It provides the orthogonal vector quantities used by later control and estimation blocks.

## Domain Context

The Clarke transform is the stationary-frame projection used in many three-phase motor-control systems to convert measured phase currents or voltages into a two-axis orthogonal representation. It is foundational to field-oriented control because it reduces three coupled phase quantities into a cleaner control-space description.

## Problem Solved

Three-phase signals are awkward to regulate directly because they are coupled and constrained by the phase-sum relationship. A dedicated Clarke transform standardizes the conversion into a compact vector form so the rest of the control stack can reason geometrically rather than phase by phase.

## Typical Use Cases

- Converting reconstructed phase currents into alpha-beta current for FOC.
- Projecting commanded phase voltages into a stationary control frame.
- Providing a common vector representation for observers and modulation stages.
- Supporting analysis and debug of current-vector trajectories in motor drives.

## Interfaces and Signal-Level Behavior

- Inputs are typically phase A, B, and optionally C currents or voltages plus validity metadata.
- Outputs provide alpha and beta components with aligned valid signaling.
- Control registers may configure scaling convention, sensor polarity mapping, and optional bypass or reduced-sensor mode.
- Diagnostic outputs can expose sum-of-phases residuals or saturation indicators.

## Parameters and Configuration Knobs

- Input and output numeric precision.
- Support for full three-phase versus inferred third-phase operation.
- Scaling convention, such as power-invariant or amplitude-invariant form.
- Optional offset-correction or clipping mode before transformation.

## Internal Architecture and Dataflow

The block generally contains a small matrix multiply or equivalent fixed-coefficient arithmetic plus validity propagation. The contract should define the exact transform convention and sign choices because later Park and inverse Park transforms must match them precisely.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed to be sampled consistently and to satisfy the expected phase relationship or at least carry validity information when they do not. Reset clears any pipeline state. If one phase is inferred, the inference rule must be documented exactly.

## Latency, Throughput, and Resource Considerations

Resource cost is low to moderate depending on precision. Latency is typically small but should be deterministic so current-loop scheduling remains predictable. Fixed-point scaling quality matters more than raw throughput.

## Verification Strategy

- Check transform outputs against a numerical reference for balanced and unbalanced phase inputs.
- Verify scaling and sign convention over the full dynamic range.
- Stress invalid or missing-phase cases to ensure validity flags remain trustworthy.
- Confirm inverse relationships with complementary transform blocks where applicable.

## Integration Notes and Dependencies

Clarke Transform usually follows Current Reconstruction and feeds Park Transform, Flux Observer, and diagnostics. It must share conventions with those consumers or the entire control frame interpretation breaks.

## Edge Cases, Failure Modes, and Design Risks

- A sign or scaling mismatch here can destabilize every downstream control loop.
- If inferred third-phase logic is implicit, debugging sensor faults becomes much harder.
- Silent clipping before transformation can distort observer behavior under load transients.

## Related Modules In This Domain

- current_reconstruction
- park_transform
- flux_observer
- space_vector_pwm

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Clarke Transform module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
