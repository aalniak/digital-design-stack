# Click Detector

## Overview

Click Detector identifies brief impulsive events in hydrophone or beamformed data and emits timestamped detections with amplitude and quality metadata. It is tuned for transient acoustic structure rather than the persistent signatures emphasized by passive tonal detectors.

## Domain Context

Click detection focuses on short, impulsive acoustic events that matter in biologics monitoring, some active-interference environments, and transient contact analysis. In sonar and broader underwater acoustics, these events require different handling than continuous tonals because time localization matters more than long spectral integration.

## Problem Solved

Short transients can be easy to miss in detectors optimized for broadband dwell or narrowband persistence. A dedicated click detector is needed to catch impulses with tight timing accuracy, reject electrical glitches, and keep biologic or transient-event analytics from being buried in continuous-stream processing.

## Typical Use Cases

- Detecting biologic clicks or other transient underwater acoustic events in long recordings.
- Flagging impulsive interference or impact noise that should be excluded from passive analyses.
- Triggering high-rate recording around short events of interest.
- Providing event timestamps for later localization using multi-sensor click arrival differences.

## Interfaces and Signal-Level Behavior

- Inputs are usually raw or beamformed acoustic samples with valid markers and optional timestamps.
- Outputs include click_detected, event_time, peak_level, duration estimate, and quality or artifact flags.
- Control registers set bandpass selection, thresholding method, refractory interval, and event-window length.
- Optional debug outputs expose envelope, energy, or matched transient score around each candidate event.

## Parameters and Configuration Knobs

- Detection band or prefilter selection and supported sample rate range.
- Threshold levels, refractory time, and minimum or maximum event duration.
- Amplitude representation and peak-hold precision for reported click metrics.
- Number of queued events that can be buffered before host or downstream logic consumes them.

## Internal Architecture and Dataflow

A common design uses band-limiting or whitening, an envelope or short-time energy detector, a threshold and refractory stage, and an event formatter. The important sonar-specific behavior is precise timestamping of the onset or peak of the impulsive event so later multilateration or biologics analysis remains meaningful.

## Clocking, Reset, and Timing Assumptions

The module assumes front-end clipping and electrical glitches can be distinguished to some extent through band limits or artifact checks, but it should still surface uncertainty when that distinction is weak. Reset clears refractory timers and pending event state.

## Latency, Throughput, and Resource Considerations

Because click detectors rely on short windows, latency can be low. Throughput must match continuous incoming samples, but resource cost is generally moderate. Event buffering matters when bursty biologic scenes generate many detections in a short interval.

## Verification Strategy

- Inject synthetic impulses of varying width and amplitude to confirm onset timing and threshold behavior.
- Replay real or representative noise scenes with electrical glitches to test artifact rejection.
- Verify refractory logic prevents multiple detections on one ringing event while still separating nearby real clicks.
- Check that reported event timestamps are consistent across filter settings and pipeline latency changes.

## Integration Notes and Dependencies

Click Detector often feeds Passive Spectrogram, localization software, or specialized biologics analysis pipelines. It should integrate with timestamping and calibration infrastructure so detections from multiple sensors can later be aligned for source localization.

## Edge Cases, Failure Modes, and Design Risks

- Overly simple thresholding may confuse electrical spikes with real acoustic clicks.
- Filter ringing can cause duplicate event reports if refractory design is weak.
- If timestamp convention is unclear, multi-sensor localization of click events becomes unreliable.

## Related Modules In This Domain

- passive_spectrogram
- hydrophone_frontend_interface
- tdoa_estimator
- passive_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Click Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
