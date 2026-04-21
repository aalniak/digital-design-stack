# Pulse Oximetry Demodulator

## Overview

Pulse Oximetry Demodulator separates and conditions time-multiplexed optical sensor measurements into red and infrared PPG channels with usable AC and DC components. It provides the core signal extraction stage for pulse oximetry pipelines.

## Domain Context

Pulse-oximetry demodulation is the optical front-end processing stage that extracts red and infrared pulsatile and baseline components from LED-driven photoplethysmography signals. In biomedical systems it sits between LED-synchronous acquisition and higher-level SpO2 or pulse-rate interpretation.

## Problem Solved

Raw photodiode samples typically mix ambient light, LED timing phases, and pulsatile physiology. A dedicated demodulator is needed to synchronize sample phases, subtract ambient contributions, and produce clean red and infrared signals for ratio-based oxygenation analysis.

## Typical Use Cases

- Extracting red and IR PPG channels from time-multiplexed LED sampling.
- Providing AC and DC components for SpO2 estimation.
- Supporting pulse-rate and perfusion tracking in wearable or bedside oximeters.
- Validating LED timing and optical front-end behavior in biomedical hardware prototypes.

## Interfaces and Signal-Level Behavior

- Inputs are digitized photodiode samples, LED phase markers, and optional ambient-only phase indicators.
- Outputs provide demodulated red and infrared channels, AC or DC features, and valid or quality flags.
- Control interfaces configure LED timing profile, ambient subtraction mode, gain normalization, and sample decimation.
- Status signals may expose phase_sync_error, sensor_saturation, and low_perfusion indications.

## Parameters and Configuration Knobs

- Supported LED multiplexing cadence and sample precision.
- Ambient-light subtraction and averaging window settings.
- Channel count for single-site or multisite sensing.
- Optional output modes such as raw PPG, AC/DC decomposition, or ratio-friendly features.

## Internal Architecture and Dataflow

The block usually contains phase-aligned sample capture, ambient subtraction, channel accumulation, and optional filtering or AC/DC decomposition. The architectural contract should define exactly which phases correspond to which emitted outputs, because oxygen-saturation math depends on stable separation of red and infrared optical contributions.

## Clocking, Reset, and Timing Assumptions

The demodulator assumes LED drive timing and ADC sampling are synchronized closely enough that each sample can be assigned unambiguously to an illumination phase. Reset clears phase trackers and output history. If gain adaptation or calibration coefficients are external, the update boundary should be explicit to avoid mixing calibration states within one demodulation frame.

## Latency, Throughput, and Resource Considerations

Compute cost is moderate but throughput must keep up with continuous LED-synchronous acquisition. Latency is driven by phase grouping and any smoothing windows. The key tradeoff is between aggressive noise suppression and timely preservation of pulsatile detail.

## Verification Strategy

- Compare demodulated outputs against a software reference with known LED phase patterns.
- Stress ambient-light transients, low perfusion, and sensor saturation conditions.
- Verify AC and DC separation on synthetic and recorded PPG waveforms.
- Check phase-sync loss detection and recovery without channel swapping or stale output reuse.

## Integration Notes and Dependencies

Pulse Oximetry Demodulator typically feeds Heart Rate Estimator, Patient Alarm Block, and higher-level SpO2 ratio computation outside this current module set. It should align with Motion Artifact Rejector and Medical Data Framer so signal-quality context stays attached to derived optical metrics.

## Edge Cases, Failure Modes, and Design Risks

- A phase-assignment error can completely corrupt SpO2 computation while leaving waveforms superficially plausible.
- Ambient subtraction that is too aggressive can erase valid pulsatile content under low perfusion.
- If demodulated channels are not clearly labeled and time-aligned, downstream ratio calculations become fragile.

## Related Modules In This Domain

- heart_rate_estimator
- motion_artifact_rejector
- patient_alarm_block
- medical_data_framer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pulse Oximetry Demodulator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
