# QRS Detector

## Overview

QRS Detector analyzes filtered ECG and emits candidate beat events corresponding to QRS complexes, along with timing and confidence metadata. It provides the discrete cardiac event stream used by later heart-rate and rhythm logic.

## Domain Context

QRS detection is the core event-extraction step in many ECG processing pipelines because it identifies ventricular depolarization timing, which anchors heart-rate estimation and many rhythm analyses. In biomedical systems it must balance sensitivity with robustness to motion and noise.

## Problem Solved

Heart rate and many arrhythmia features depend on accurate beat timing rather than on the raw waveform alone. A dedicated detector is needed so thresholding, refractory behavior, and morphology-based discrimination are explicit and testable.

## Typical Use Cases

- Detecting R peaks for heart-rate calculation in bedside and wearable monitors.
- Generating beat events for rhythm-variability or interval analysis.
- Providing a robust event stream for alarm logic and logging.
- Supporting benchmarking against annotated ECG datasets in biomedical hardware.

## Interfaces and Signal-Level Behavior

- Inputs are filtered ECG samples with valid timing and optional lead or quality indicators.
- Outputs provide qrs_detected events, beat timestamps, confidence or quality metrics, and refractory status.
- Control interfaces configure threshold policy, refractory interval, adaptive baseline behavior, and multi-lead combination mode if supported.
- Status signals may expose missed_beat suspicion, detector_saturation, and signal_quality warnings.

## Parameters and Configuration Knobs

- Sample-rate dependent refractory and integration window settings.
- Input precision and event timestamp width.
- Single-lead versus multilead support.
- Adaptive threshold or morphology scoring options.

## Internal Architecture and Dataflow

A QRS detector often combines preprocessing envelopes or derivatives, energy or slope integration, adaptive thresholding, and a refractory guard that suppresses duplicate detections. The architectural contract should state whether output timestamps correspond to threshold crossing, local peak, or a latency-corrected beat location, because that changes interval measurement downstream.

## Clocking, Reset, and Timing Assumptions

The detector assumes upstream filtering has already reduced baseline drift and high-frequency noise enough for its threshold model to be meaningful. Reset clears adaptation and refractory state. If signal-quality inputs are available, the block should specify whether it suppresses detections under low quality or merely flags them as low confidence.

## Latency, Throughput, and Resource Considerations

Compute cost is low to moderate, but correctness under noisy ambulatory conditions is the central performance concern. Latency is typically short and bounded, though some algorithms intentionally delay output to refine peak timing. The key tradeoff is sensitivity versus false positives during motion and ectopic morphology.

## Verification Strategy

- Compare detections against annotated ECG datasets across normal rhythm, tachycardia, bradycardia, and noisy conditions.
- Stress refractory logic with premature beats and double-peak morphologies.
- Check timestamp convention and delay compensation against a software detector reference.
- Verify quality-flag behavior under clipped, disconnected, or artifact-heavy signals.

## Integration Notes and Dependencies

QRS Detector feeds Heart Rate Estimator, Patient Alarm Block, and Medical Data Framer and usually sits downstream of ECG Bandpass Filter and Motion Artifact Rejector. It should align with the broader patient-monitor timing model so beat events remain traceable back to source samples.

## Edge Cases, Failure Modes, and Design Risks

- A detector can look accurate on clean bench data but fail under motion or electrode disturbance.
- Poorly documented timestamp semantics will bias RR interval and heart-rate calculations downstream.
- Too-aggressive adaptive thresholds may suppress true low-amplitude beats after large artifacts.

## Related Modules In This Domain

- ecg_bandpass_filter
- heart_rate_estimator
- motion_artifact_rejector
- patient_alarm_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the QRS Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
