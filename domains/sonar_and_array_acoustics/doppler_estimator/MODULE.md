# Doppler Estimator

## Overview

Doppler Estimator measures frequency or phase-rate offsets associated with target or platform motion and emits a motion-relevant observable for later classification or tracking. It can operate on beamformed tones, matched-filter outputs, or narrowband spectral features depending on the sonar architecture.

## Domain Context

Doppler estimation in sonar extracts relative radial motion from frequency shift or time-scale change in the received acoustic signature. It is valuable in both active and passive systems because motion cues help separate stationary clutter from moving contacts and improve tracker state estimation.

## Problem Solved

Contact detection alone does not reveal whether an observed return is approaching, receding, or stationary relative to the platform. Ad hoc Doppler calculations scattered across later software often lose traceability to the exact beam, sample window, or signal model that produced the estimate.

## Typical Use Cases

- Estimating radial velocity from active returns after matched filtering or coherent processing.
- Tracking tonal line drift in passive monitoring of vessels or machinery.
- Filtering out stationary environmental clutter when moving contacts are operationally interesting.
- Providing velocity observables to a multi-target tracker for better kinematic discrimination.

## Interfaces and Signal-Level Behavior

- Inputs may be coherent pulse returns, phase histories, spectral peak tracks, or narrowband beam outputs.
- Outputs usually include Doppler estimate, sign, confidence, timestamp, and source or beam identifier.
- Controls define coherent integration length, search range, unwrap behavior, and smoothing constants.
- Diagnostic interfaces often expose residual phase error, peak ratios, or neighboring spectral bins for debugging.

## Parameters and Configuration Knobs

- Maximum Doppler range and frequency resolution or fixed-point precision.
- Window length and coherent accumulation depth used to stabilize the estimate.
- Choice of estimator family such as phase-difference, FFT peak, or matched-bank selection.
- Optional compensation for platform motion or nominal carrier frequency.

## Internal Architecture and Dataflow

A typical design contains a feature extractor, Doppler measurement core, unwrap or sign logic, and a confidence calculator. In sonar the estimator must make its observation model explicit, because the meaning of Doppler changes depending on whether the input is a continuous passive tonal, a burst-mode coherent return, or an already beamformed contact track.

## Clocking, Reset, and Timing Assumptions

The estimator assumes a stable enough sample clock and carrier or bin reference that motion-induced shifts are distinguishable from local oscillator or platform timing drift. Reset clears history and smoothing state so old phase trajectories do not bleed into a new contact.

## Latency, Throughput, and Resource Considerations

Computation is modest for single-line or phase-difference methods and heavier for search-based estimators over wide velocity hypotheses. Latency is usually tied to integration time rather than arithmetic depth, which means better accuracy naturally costs slower updates.

## Verification Strategy

- Inject synthetic Doppler shifts with known sign and magnitude across the supported range.
- Check wrap and ambiguity behavior near zero shift and near the search boundaries.
- Verify reported timestamps correspond to the center of the coherent interval used to form the estimate.
- Replay passive tonal scenes and active return sequences against a floating-point reference implementation.

## Integration Notes and Dependencies

Doppler Estimator often consumes outputs from Matched Filter, Passive Spectrogram, or beamforming stages and feeds Target Tracker or classification logic. It should preserve enough metadata for downstream software to understand which beam, range cell, or line track produced the measurement.

## Edge Cases, Failure Modes, and Design Risks

- Short integration windows may yield noisy estimates that destabilize trackers.
- Platform motion compensation errors can be misread as target motion.
- An undocumented sign convention can invert approaching versus receding interpretations downstream.

## Related Modules In This Domain

- matched_filter
- passive_spectrogram
- target_tracker
- bearing_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Doppler Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
