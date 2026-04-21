# Passive Spectrogram

## Overview

Passive Spectrogram computes and frames time-frequency representations of sonar input streams for passive analysis. It packages FFT-based spectral slices, power estimates, and associated metadata into a form that later detection, visualization, or archival blocks can consume efficiently.

## Domain Context

The passive spectrogram module is the spectral workhorse of passive sonar analysis. It turns long acoustic streams into a time-frequency view that operators, detectors, and machine classifiers can use to find tonals, transients, and modulation structures associated with contacts in the underwater environment.

## Problem Solved

Raw time-domain data hides many passive signatures that only become obvious in the frequency domain. Without a dedicated spectrogram module, every downstream tool must rebuild FFT framing, windowing, scaling, and bin labeling independently, which leads to inconsistent interpretation of narrowband and transient content.

## Typical Use Cases

- Producing waterfall or spectrogram data for operator review and recording.
- Providing tonal and band-energy features to a passive detector or classifier.
- Monitoring cavitation lines, shaft harmonics, or biologic calls over long listening intervals.
- Summarizing high-rate hydrophone streams into a compact analysis product for storage or telemetry.

## Interfaces and Signal-Level Behavior

- Input is generally a continuous real or complex sample stream from a channel or beam, with valid markers and timestamps.
- Outputs consist of FFT frames or power spectra with frame indices, time tags, and optional log-scaled magnitudes.
- Control registers select FFT size, overlap, window type, averaging depth, and bin output format.
- Status interfaces may indicate frame overruns, scaling saturation, and whether spectral statistics are stable.

## Parameters and Configuration Knobs

- FFT length, overlap factor, and supported analysis window family.
- Magnitude format such as linear power, magnitude squared, or log-compressed output.
- Number of simultaneous channels or beams and optional accumulation depth across frames.
- Frequency-bin pruning or band-selection support when only part of the spectrum is operationally relevant.

## Internal Architecture and Dataflow

A typical implementation includes window buffering, FFT execution, magnitude or power conversion, optional averaging, and frame formatting. The domain-specific emphasis is on preserving time tagging and consistent frequency labeling so tonal persistence and Doppler-like drift can be interpreted over long dwell periods.

## Clocking, Reset, and Timing Assumptions

The spectrogram assumes stable sample timing and a known sample rate so bins map to physical frequency correctly. Reset clears partial windows and averaging history. If overlap is enabled, buffer management must preserve continuity across frame boundaries to avoid spectral scalloping or dropped time slices.

## Latency, Throughput, and Resource Considerations

Resource use scales with FFT size, channel count, and overlap. Latency is at least one analysis window plus FFT pipeline depth, which is usually acceptable for passive monitoring. Throughput must sustain continuous frame generation, especially when high-overlap settings are used to resolve short transients.

## Verification Strategy

- Inject tones, chirps, and impulses to confirm frequency-bin placement, leakage behavior, and time resolution.
- Verify overlap and window settings against a software spectrogram reference.
- Check scaling across very weak and very strong lines so saturation or underflow is understood.
- Ensure frame timestamps correspond to the intended analysis window center or edge as documented.

## Integration Notes and Dependencies

Passive Spectrogram often feeds Passive Detector, operator display software, archival recorders, or classifier features. It should integrate with navigation and beam metadata when spectrograms are derived from steerable beams, because interpretation depends on where the array was listening.

## Edge Cases, Failure Modes, and Design Risks

- Incorrect timestamp convention can offset detections and confuse tracker alignment.
- Changing FFT or window configuration without updating downstream expectations can break learned thresholds and visual scales.
- If overlap bookkeeping is wrong, spectrogram gaps may appear only under sustained long recordings and be hard to diagnose.

## Related Modules In This Domain

- passive_detector
- hydrophone_frontend_interface
- bearing_estimator
- click_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Passive Spectrogram module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
