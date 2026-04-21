# Doppler Flow Estimator

## Overview

Doppler Flow Estimator derives blood-flow velocity or flow-related metrics from Doppler ultrasound signal features such as frequency shift or spectral envelope. It provides a hemodynamic interpretation stage for Doppler ultrasound pipelines.

## Domain Context

Doppler flow estimation is a biomedical ultrasound-derived metric stage that converts Doppler-shifted echoes into blood-flow velocity or related hemodynamic measures. In this domain it sits between raw Doppler signal conditioning and clinician-facing numeric or waveform outputs.

## Problem Solved

Doppler signals contain clutter, angle dependence, and spectral variation that are not directly meaningful until processed into velocity-like estimates. A dedicated estimator makes the conversion rules, angle assumptions, and confidence semantics explicit.

## Typical Use Cases

- Estimating blood-flow velocity from pulsed or continuous-wave Doppler data.
- Providing flow trends or peak-velocity metrics to ultrasound systems.
- Supporting vascular or cardiac Doppler feature extraction in hardware pipelines.
- Evaluating Doppler signal-processing strategies in biomedical research devices.

## Interfaces and Signal-Level Behavior

- Inputs are Doppler-processed signal streams or spectral features plus timing and beam metadata.
- Outputs provide estimated velocity, flow-related metrics, and validity or confidence flags.
- Control interfaces configure angle correction, spectral-window policy, and estimator mode such as mean or peak velocity.
- Status signals may expose angle_invalid, low_signal, and clutter_dominant conditions.

## Parameters and Configuration Knobs

- Input spectral or signal precision.
- Supported estimator modes and averaging windows.
- Angle-correction coefficient format.
- Update rate and output metric set.

## Internal Architecture and Dataflow

The block generally contains peak or centroid extraction, clutter rejection hooks, angle correction, and output smoothing or formatting. The critical contract is whether the estimator output is angle-corrected physical velocity, uncorrected Doppler proxy, or a relative trend metric, because those are used differently in downstream systems.

## Clocking, Reset, and Timing Assumptions

The estimator assumes upstream ultrasound beamforming and Doppler conditioning already provide a stable flow-sensitive signal. Reset clears smoothing history and confidence state. If angle correction requires external geometry, the source and trust of that geometry should be explicit.

## Latency, Throughput, and Resource Considerations

Arithmetic load is moderate, but result fidelity depends more on spectral robustness and clutter handling than on throughput. Update latency is typically acceptable at frame or beam rates. The key tradeoff is between stable estimates and responsiveness to rapid flow changes.

## Verification Strategy

- Compare outputs against a software Doppler-flow reference using synthetic and recorded Doppler spectra.
- Stress low-signal, high-clutter, and rapidly varying flow conditions.
- Verify angle-correction application and units.
- Check quality or validity behavior under ambiguous spectral content.

## Integration Notes and Dependencies

Doppler Flow Estimator commonly follows Ultrasound Beamformer and may feed Medical Data Framer or higher-level display logic. It should align with system-level ultrasound geometry and clinician-facing labeling so outputs are not misinterpreted as more physically grounded than they are.

## Edge Cases, Failure Modes, and Design Risks

- Angle-correction mistakes can produce consistently wrong velocity estimates while preserving smooth trends.
- Clutter-dominated inputs may still yield plausible numbers unless validity policy is conservative.
- If the output metric semantics are vague, host software may treat a trend estimate as an absolute physical measurement.

## Related Modules In This Domain

- ultrasound_beamformer
- medical_data_framer
- patient_alarm_block
- motion_artifact_rejector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Doppler Flow Estimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
