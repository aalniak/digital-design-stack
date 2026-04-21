# Passive Detector

## Overview

Passive Detector analyzes acoustic energy, spectral structure, or narrowband line behavior and emits candidate detections from continuous listening data. It converts beam or channel streams into event hypotheses that later tracking and classification logic can manage.

## Domain Context

Passive detection is the listening-oriented branch of the sonar stack. Instead of searching for echoes from an emitted ping, it monitors beam or channel energy for signatures of vessels, machinery, biologics, or other acoustic sources and decides when those signatures are strong and structured enough to become contacts.

## Problem Solved

Continuous passive listening generates far more data than operators or downstream software can inspect directly. A dedicated detector is needed to turn long acoustic streams into compact contact candidates while accounting for changing ambient noise, platform self-noise, and intermittent interference.

## Typical Use Cases

- Thresholding beam power for broadband transient detections.
- Monitoring tonal lines or band-limited machinery signatures over long dwell intervals.
- Triggering recording or higher-resolution analysis when a contact enters the surveillance sector.
- Generating low-rate candidate reports for fusion with navigation and classification software.

## Interfaces and Signal-Level Behavior

- Inputs may be raw beams, spectrogram bins, band-energy summaries, or other precomputed acoustic features.
- Outputs usually include detection flag, timestamp, beam or channel identifier, score, and basic confidence metadata.
- Control registers define detection thresholds, adaptive noise-estimation depth, dwell logic, and hold-off timers.
- Diagnostic outputs may expose estimated noise floor, band statistics, and intermediate detector metrics for tuning.

## Parameters and Configuration Knobs

- Number of monitored channels or beams and supported detection feature types.
- Threshold representation, integration window length, and adaptive floor averaging constants.
- Hysteresis, debounce, and retrigger rules used to avoid chatter.
- Capacity for multiple simultaneous candidate reports or priority ranking of strongest events.

## Internal Architecture and Dataflow

A passive detector often contains feature normalization, noise-floor estimation, threshold comparison, dwell or persistence logic, and an event reporter. The right architecture depends on mission goals, but the module contract should always distinguish instantaneous threshold crossings from confirmed detections that have survived temporal consistency checks.

## Clocking, Reset, and Timing Assumptions

Inputs should already be time-aligned and, when necessary, calibrated for beam gain differences. Because ambient noise can change dramatically with sea state and platform maneuver, the detector assumes its thresholds or adaptive floors are updated at a pace appropriate to the environment but not so fast that real contacts are normalized away.

## Latency, Throughput, and Resource Considerations

This block is generally light relative to beamforming, enabling many channels or beams to be monitored in parallel. Latency is driven more by dwell requirements than arithmetic depth. Throughput must support continuous operation with no dropped intervals, because passive surveillance value comes from persistence over long recordings.

## Verification Strategy

- Replay known passive scenes with inserted contacts and measure detection probability versus false alarm rate.
- Stress adaptive threshold logic through sudden noise-floor changes, platform turns, and self-noise bursts.
- Check debounce and hold-off behavior to ensure one acoustic event does not produce a flood of duplicate reports.
- Verify timestamps and beam identifiers stay aligned with the features that caused the detection.

## Integration Notes and Dependencies

Passive Detector typically consumes beamformed audio or spectrogram products and feeds Target Tracker, recorder-control logic, or classification pipelines. It benefits from integration with calibration and navigation subsystems so thresholds can be interpreted relative to beam steering and platform state.

## Edge Cases, Failure Modes, and Design Risks

- An overly aggressive adaptive floor can suppress persistent but weak contacts.
- Insufficient hold-off logic can turn one broadband transient into many false tracks.
- Poorly documented detection scores make it hard for downstream fusion to weight events correctly.

## Related Modules In This Domain

- passive_spectrogram
- bearing_estimator
- target_tracker
- reverberation_suppressor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Passive Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
