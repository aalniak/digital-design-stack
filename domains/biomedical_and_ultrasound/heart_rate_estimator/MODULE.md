# Heart Rate Estimator

## Overview

Heart Rate Estimator converts beat-event timing into heart-rate values and related confidence or rhythm-quality metrics. It provides the continuous rate output used by displays, logging, and alarm logic.

## Domain Context

Heart-rate estimation is the first clinically interpretable quantity derived from the ECG event stream in many monitoring systems. In biomedical stacks it must translate beat timing into stable rate output without hiding physiologically important irregularity or reacting wildly to one bad beat.

## Problem Solved

Beat detections alone are not enough for clinical or wearable use; systems need a stable and meaningful rate estimate with understood update latency and response to ectopy or missed beats. A dedicated estimator makes those temporal tradeoffs explicit.

## Typical Use Cases

- Displaying live BPM from QRS detections in bedside or wearable monitors.
- Feeding bradycardia or tachycardia alarm logic.
- Providing smoothed heart-rate telemetry for trend analysis.
- Serving as a validated timing-to-rate conversion stage in biomedical prototypes.

## Interfaces and Signal-Level Behavior

- Inputs are beat timestamps, beat-valid events, and optional signal-quality indicators or detector confidence.
- Outputs provide current heart rate, update-valid markers, and optional confidence or irregularity metrics.
- Control interfaces configure averaging depth, instantaneous versus smoothed mode, and timeout policy when beats disappear.
- Status signals may expose rate_invalid, asystole_timeout, and irregular_rr indicators.

## Parameters and Configuration Knobs

- Timestamp width and supported beat-rate range.
- Smoothing window or exponential averaging constants.
- Timeout thresholds for no-beat conditions.
- Optional arrhythmia-aware update policy or ectopic-beat rejection support.

## Internal Architecture and Dataflow

The estimator usually computes RR intervals, converts interval to BPM or equivalent, and applies smoothing or quality gating as configured. The contract should define whether output is instantaneous rate, averaged rate, or quality-weighted rate, because those can diverge significantly during arrhythmia or motion.

## Clocking, Reset, and Timing Assumptions

The module assumes incoming beat events are trustworthy enough that occasional false detections do not dominate the output. Reset clears rate history and should mark rate invalid until sufficient beats have been observed. If beat quality flags are used, the estimator should document how they influence smoothing or invalidation.

## Latency, Throughput, and Resource Considerations

Arithmetic load is light, but output stability versus responsiveness is the key performance tradeoff. Fast updates help responsiveness but make artifacts visible; heavy smoothing improves displays but can delay clinically relevant alarms. Throughput is trivial relative to ECG sample-rate blocks.

## Verification Strategy

- Compare rate output against a software reference on annotated beat-event sequences.
- Stress missed beats, false double detections, and abrupt rate changes.
- Verify timeout behavior when no beats arrive.
- Check consistency between instantaneous and smoothed modes across representative RR interval patterns.

## Integration Notes and Dependencies

Heart Rate Estimator commonly consumes QRS Detector output and feeds Patient Alarm Block, Medical Data Framer, and user-facing telemetry. It should align with monitor UI and alarm policies on whether displayed rate is immediate, averaged, or quality-gated.

## Edge Cases, Failure Modes, and Design Risks

- Over-smoothing can hide rapid physiologic changes or delay alarms.
- Overly reactive estimation can turn one false beat into a large displayed BPM jump.
- If invalid-rate and stale-rate semantics are unclear, downstream alarm logic may overtrust old values.

## Related Modules In This Domain

- qrs_detector
- patient_alarm_block
- medical_data_framer
- ecg_bandpass_filter

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Heart Rate Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
