# Bioimpedance Demodulator

## Overview

Bioimpedance Demodulator extracts magnitude or phase-related impedance information from a modulated electrical measurement channel. It provides a conditioned impedance waveform or metric stream for downstream physiologic estimation.

## Domain Context

Bioimpedance demodulation converts an injected high-frequency measurement current and sensed voltage response into a lower-rate impedance-related signal. In biomedical systems it underlies respiration monitoring, body-composition sensing, and certain instrumentation workflows.

## Problem Solved

Raw bioimpedance measurements are carried on a carrier or excitation pattern and can be contaminated by motion, electrode behavior, and front-end noise. A dedicated demodulator is needed to recover the slow physiologic content or impedance metric in a controlled way.

## Typical Use Cases

- Deriving respiration waveforms from thoracic impedance measurements.
- Recovering impedance changes for body-composition or fluid-status sensing prototypes.
- Conditioning synchronous measurement channels in biomedical instrumentation.
- Providing low-rate impedance features to respiratory estimators or recorders.

## Interfaces and Signal-Level Behavior

- Inputs are digitized measurement samples, excitation-phase or reference information, and optional channel or lead identifiers.
- Outputs provide demodulated impedance waveform, magnitude estimates, and validity or quality flags.
- Control interfaces configure synchronous detection mode, carrier or reference profile, filtering, and output decimation.
- Status signals may expose reference_sync_lost, saturation, and low_signal conditions.

## Parameters and Configuration Knobs

- Input precision and reference phase resolution.
- Supported excitation frequencies or phase profiles.
- Output decimation and low-pass filter settings.
- Single-channel versus multichannel support.

## Internal Architecture and Dataflow

The block generally contains synchronous mixing or phase-sensitive detection, low-pass filtering, and optional magnitude or phase extraction. The architectural contract should state whether the output is raw demodulated I/Q-like content, magnitude only, or a further conditioned physiologic waveform, because those interpretations are not interchangeable downstream.

## Clocking, Reset, and Timing Assumptions

The demodulator assumes stable timing between excitation and sampled response. Reset clears filter and phase state. If excitation reference arrives from another subsystem, the trust and latency assumptions of that reference should be documented, because phase error directly corrupts demodulation quality.

## Latency, Throughput, and Resource Considerations

Resource cost is moderate and driven by synchronous detection arithmetic and filtering. Throughput must keep pace with the sampled measurement stream, though output rate is usually much lower after decimation. The main tradeoff is between noise rejection and temporal responsiveness of the recovered impedance signal.

## Verification Strategy

- Compare demodulated results against a software synchronous-detection reference for representative impedance waveforms.
- Stress phase offsets, amplitude drift, and motion-like disturbances.
- Verify output semantics for magnitude-only versus I/Q-like modes.
- Check decimation and filter delay so downstream respiratory estimation aligns to the correct time base.

## Integration Notes and Dependencies

Bioimpedance Demodulator commonly feeds Respiration Rate Estimator and Medical Data Framer and may interact with Motion Artifact Rejector if ambulatory use is expected. It should align with the excitation-generation subsystem on phase and calibration assumptions.

## Edge Cases, Failure Modes, and Design Risks

- Reference phase mismatch can make demodulated output drift or collapse without obvious hard faults.
- If output semantics are vague, downstream estimation may apply the wrong interpretation to magnitude and phase content.
- Aggressive filtering can stabilize the signal but delay clinically relevant respiratory transitions.

## Related Modules In This Domain

- respiration_rate_estimator
- motion_artifact_rejector
- medical_data_framer
- patient_alarm_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Bioimpedance Demodulator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
