# Bearing Estimator

## Overview

Bearing Estimator converts spatial sonar measurements into one or more azimuth or relative-angle estimates with associated confidence metrics. Depending on architecture, it may operate on beam power scans, phase differences, or TDOA features and provide a stabilized bearing stream for higher-level contact management.

## Domain Context

Bearing estimation turns beamformed or phase-derived sonar observables into a directional contact estimate. In the sonar stack it sits close to the perception boundary, where raw acoustic energy becomes a navigationally meaningful angle that can feed trackers, operator displays, or autonomy software.

## Problem Solved

A detector that only says signal is present is not enough for navigation or tracking. Systems need a repeatable method to map array response into direction while accounting for ambiguous lobes, array geometry, and uncertainty, otherwise target localization becomes inconsistent across frequencies and operating modes.

## Typical Use Cases

- Selecting the best bearing from a beam bank produced by a delay-and-sum beamformer.
- Estimating angle from phase or delay measurements on compact hydrophone clusters.
- Stabilizing operator displays with confidence-weighted bearing outputs during passive search.
- Supplying initial direction observations to a multi-contact target tracker.

## Interfaces and Signal-Level Behavior

- Inputs may be beam power vectors, phase-difference estimates, or TDOA measurements with timestamps.
- Outputs usually include bearing angle, confidence or covariance, ambiguity flags, and source identifiers.
- Control registers define search sector, smoothing depth, array geometry mode, and ambiguity-resolution policy.
- Optional diagnostic outputs expose peak beam index, lobe ratios, and residual error metrics for tuning.

## Parameters and Configuration Knobs

- Angular search resolution, beam count, and allowed smoothing or dwell length.
- Representation of angle units such as degrees, radians, or fixed-point steering bins.
- Thresholds for declaring confidence, rejecting sidelobe candidates, and handling front-back ambiguity.
- Number of simultaneous candidate peaks retained before later tracking resolves them.

## Internal Architecture and Dataflow

Implementation often combines a peak search, interpolation or centroid stage, ambiguity logic, temporal smoothing, and a confidence calculator. The exact estimator can remain simple, but the module contract must clearly state whether it is reporting instantaneous array maxima, smoothed kinematic bearings, or ambiguity-limited candidates so downstream fusion interprets the output correctly.

## Clocking, Reset, and Timing Assumptions

Inputs are assumed to already be synchronized and associated with a known array configuration. The estimator should not hide poor observability; when the beam pattern is flat or ambiguous, it is better to emit low confidence than a deceptively precise angle. Reset clears smoothing history and candidate state.

## Latency, Throughput, and Resource Considerations

Computation is generally light compared with beamforming, but latency matters because trackers often consume each bearing at pulse or frame rate. Resource use rises when multiple contacts, interpolation, or covariance estimation are supported. Deterministic output cadence is more valuable than absolute minimum latency.

## Verification Strategy

- Feed synthetic beam patterns and confirm the reported bearing tracks the known source direction across the full search sector.
- Exercise front-back ambiguity, near-equal sidelobes, and low-SNR conditions to ensure confidence reporting is honest.
- Verify smoothing logic does not lag unacceptably during rapid bearing changes.
- Check fixed-point angle quantization and interpolation error against a floating-point reference.

## Integration Notes and Dependencies

Bearing Estimator commonly follows Delay-and-Sum Beamformer or TDOA Estimator and feeds Target Tracker, mission logic, or operator visualization. It should preserve timestamps and confidence metadata so later fusion can weight directional updates appropriately against navigation uncertainty and platform maneuvers.

## Edge Cases, Failure Modes, and Design Risks

- Selecting the strongest lobe blindly can lock onto sidelobes or multipath rather than the true source direction.
- Over-smoothed bearings may appear stable while systematically lagging maneuvering targets.
- Reporting high confidence when observability is weak can poison downstream tracking filters.

## Related Modules In This Domain

- delay_and_sum_beamformer
- tdoa_estimator
- target_tracker
- passive_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bearing Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
