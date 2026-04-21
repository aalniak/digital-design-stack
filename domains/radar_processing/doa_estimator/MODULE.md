# Direction of Arrival Estimator

## Overview

The direction of arrival estimator derives target angle estimates from array data or beam-space data using a chosen estimation method. It is a higher-level angle inference block built on coherent spatial processing.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Angle FFTs and beams provide spatial evidence, but many systems ultimately need explicit angle estimates and confidence rather than raw spectra. This module performs that conversion while making the estimation method and coordinate conventions explicit.

## Typical Use Cases

- Estimating target bearing from array data or angle spectra.
- Converting beam-space peaks into explicit angle reports.
- Providing reusable angle inference in radar perception pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts array snapshots, beam outputs, or angle-spectrum data plus optional detection context.
- Output side emits angle estimates, confidence, and associated target metadata.
- Control side configures estimation method, search range, and output formatting.

## Parameters and Configuration Knobs

- Input precision, angle resolution, output width, and estimation mode.
- Peak-picking thresholds, covariance or beam-space mode selection, and maximum target count.
- Runtime profile selection and coordinate-system convention.

## Internal Architecture and Dataflow

The estimator uses the supplied spatial information to compute one or more angle hypotheses according to the selected method, which may be simple peak selection or a richer subspace-inspired estimate if supported. The documentation should state what input domain is expected and whether outputs are discrete bins, interpolated angles, or another parameterization.

## Clocking, Reset, and Timing Assumptions

The spatial input must already share the documented array geometry, calibration state, and ordering. Reset should clear any per-snapshot state or accumulation used by the estimator.

## Latency, Throughput, and Resource Considerations

DOA estimation ranges from light to moderate in cost depending on method complexity and target multiplicity. Resource use depends on whether the estimator works directly on spectra or on richer covariance-like information.

## Verification Strategy

- Compare angle estimates against a reference estimator on simulated single-target and multitarget scenes.
- Check coordinate convention, confidence output, and target-count limits.
- Verify behavior when the input spectrum is ambiguous or nearly flat.

## Integration Notes and Dependencies

This block often sits after angle FFT or beamforming and before target reporting, so its output convention should be documented with trackers and display overlays. Integrators should also note whether reported angles are broadside-relative, boresight-relative, or another frame.

## Edge Cases, Failure Modes, and Design Risks

- A broadside-versus-bearing convention mismatch can make all reported angles appear mirrored or shifted.
- Sparse or noisy spectra may create unstable outputs if confidence semantics are ignored downstream.
- If the block assumes one dominant target but the scene is multipath rich, outputs may look precise but be misleading.

## Related Modules In This Domain

- angle_fft
- digital_beamformer
- target_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Direction of Arrival Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
