# TDOA Estimator

## Overview

TDOA Estimator measures relative arrival-time offsets between channels, beams, or subarrays and emits delay observations suitable for bearing or localization logic. It converts waveform similarity into a physically interpretable delay metric that later stages can map into direction or position.

## Domain Context

The TDOA estimator serves compact hydrophone clusters and distributed acoustic baselines that infer direction or position from arrival-time differences rather than explicit beam scanning. In sonar systems it is especially useful when aperture size, compute budget, or downstream fusion architecture favors pairwise delay measurements over a full beam bank.

## Problem Solved

Many underwater localization methods start with relative timing, but raw cross-correlation peaks are noisy, ambiguous, and hard to compare across baselines if each consumer rolls its own estimator. A dedicated TDOA block creates a consistent contract for lag search, peak qualification, and uncertainty reporting.

## Typical Use Cases

- Estimating bearing from short-baseline hydrophone clusters using inter-sensor delay.
- Producing pairwise delay observations for multilateration or tracker-side geometry solvers.
- Cross-checking beamformer steering results with a simpler timing-based measurement path.
- Measuring calibration offsets between array channels during controlled source tests.

## Interfaces and Signal-Level Behavior

- Inputs are usually pairs or sets of synchronized sample streams, sometimes already beamformed or band-limited.
- Outputs include estimated lag, correlation strength, sign of delay, validity, and optional uncertainty metrics.
- Control registers define lag search range, interpolation method, peak ratio thresholds, and averaging windows.
- Optional diagnostic ports expose the raw or decimated cross-correlation neighborhood around the selected peak.

## Parameters and Configuration Knobs

- Maximum supported lag in samples and fractional-delay interpolation precision.
- Number of channel pairs processed concurrently and whether pair scheduling is static or programmable.
- Input sample format, correlation accumulator width, and normalization mode.
- Peak quality thresholds used to reject ambiguous, multipath-dominated, or low-energy estimates.

## Internal Architecture and Dataflow

Typical structure includes windowing, cross-correlation or GCC-style weighting, peak search, optional parabolic interpolation, and a confidence calculator. In sonar the architecture often benefits from band-limiting or whitening because reverberation and shipping noise can otherwise broaden correlation peaks and make delay estimates unstable.

## Clocking, Reset, and Timing Assumptions

The estimator assumes channels are time-aligned to a shared sample clock apart from the physical propagation delay being measured. Any static cable or converter offsets should either be calibrated out beforehand or explicitly subtracted in this block. Reset clears running averages and any stale correlation state between measurement windows.

## Latency, Throughput, and Resource Considerations

Computation depends on lag depth and number of active pairs. Throughput must match the chosen measurement cadence, which may be every sample window rather than every sample. Latency should be bounded and reported because tracker-side fusion often needs to align the delay estimate with platform pose and acoustic event time.

## Verification Strategy

- Inject synthetic delays across clean tones, wideband bursts, and noisy broadband signals to confirm accuracy and bias.
- Exercise ambiguous multipath cases to ensure the module reports low confidence rather than unstable delays.
- Verify static calibration offsets are applied with correct sign and channel ordering.
- Compare interpolated lag results against a high-precision software reference over the full search range.

## Integration Notes and Dependencies

TDOA Estimator often feeds Bearing Estimator or a geometry solver outside the FPGA. It integrates closely with hydrophone framing, channel calibration tables, and timestamping so reported lags can be fused with known array geometry and platform motion.

## Edge Cases, Failure Modes, and Design Risks

- Pair ordering mistakes invert the sign of delay and therefore the interpreted direction.
- Strong reverberation can create attractive but false correlation peaks if quality metrics are too permissive.
- If observation timestamps do not match the sampled window, localization filters can drift even when the lag estimate itself is numerically correct.

## Related Modules In This Domain

- bearing_estimator
- delay_and_sum_beamformer
- array_calibration
- target_tracker

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the TDOA Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
