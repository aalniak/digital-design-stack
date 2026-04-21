# Digital Beamformer

## Overview

The digital beamformer combines calibrated array channels using complex weights to form one or more directional receive beams. It is the spatial-focusing stage that can precede angle FFTs or act as a direct beam selector.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Array radar gains much of its value from directional selectivity, but that selectivity only appears when channels are weighted and summed coherently. This module provides that beam synthesis step with a documented coordinate and weight contract.

## Typical Use Cases

- Forming steerable receive beams from calibrated array channels.
- Reducing spatial search space before later detection or tracking.
- Providing reusable directional combining in phased-array radar systems.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent channel vectors arranged by antenna element.
- Output side emits one or more beam signals and optional beam-index or energy metadata.
- Control side loads beam weights, selects beams, and manages bank switching or steering updates.

## Parameters and Configuration Knobs

- Channel count, beam count, weight precision, and output width.
- Complex versus real weighting, bank count, and runtime steering-update policy.
- Optional normalization or per-beam gain control.

## Internal Architecture and Dataflow

The beamformer applies complex weights to each channel and sums the results to create one or more directional beams. It may operate directly on time samples or on selected range-Doppler cells depending on placement. The contract should define beam ordering, angle convention, and whether several beams are formed simultaneously or time multiplexed.

## Clocking, Reset, and Timing Assumptions

All channels must be calibrated and phase aligned according to the documented array geometry. Reset should select a known beam bank or neutral beam state.

## Latency, Throughput, and Resource Considerations

Beamforming cost scales with channel count, beam count, and complex arithmetic precision. Resource use can be significant if many beams are produced in parallel.

## Verification Strategy

- Compare beam responses against a reference array model for several steering directions and calibration cases.
- Check beam ordering, steering updates, and coefficient-bank switching.
- Verify output scaling and coherent-sum headroom on strong targets.

## Integration Notes and Dependencies

This block often follows array calibration and may feed detection directly or precede angle FFT or DOA estimation, so its beam-angle convention should be documented with those consumers. Integrators should also note whether beam weights are static, schedule-driven, or adaptive.

## Edge Cases, Failure Modes, and Design Risks

- A beam-order or angle-convention mismatch can rotate the radar field of view silently.
- If calibration is omitted or stale, beam patterns will degrade even when the beamformer logic is correct.
- Mid-frame weight updates can destroy coherence if not synchronized carefully.

## Related Modules In This Domain

- array_calibration
- angle_fft
- doa_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Digital Beamformer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
