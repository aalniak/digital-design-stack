# Acoustic Localizer

## Overview

The acoustic localizer estimates the direction or position of a sound source from multi-microphone input, usually by exploiting timing, phase, or beam response differences. It is a spatial-analysis block rather than a conventional audio-effect stage.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Microphone arrays capture spatial information, but that information must be converted into usable direction or position estimates with explicit array geometry and timing assumptions. This module provides that localization computation in a reusable hardware form.

## Typical Use Cases

- Estimating speaker direction in smart-speaker or conferencing systems.
- Providing acoustic source localization for robotics and sensing.
- Supporting research on array-based acoustic direction finding.

## Interfaces and Signal-Level Behavior

- Input side accepts time-aligned multi-microphone sample streams or subband features.
- Output side emits direction-of-arrival, source-position, or confidence estimates.
- Control side configures array geometry, search space, and estimation mode or calibration data.

## Parameters and Configuration Knobs

- Channel count, sample width, geometry representation, and estimator precision.
- Subband versus time-domain mode, search-grid resolution, and output update cadence.
- Calibration or channel-delay compensation support.

## Internal Architecture and Dataflow

Localization implementations may compute inter-channel delays, phase differences, beam-power scans, or related spatial measures and then select the most likely source direction. The module contract should identify which class of estimator is implemented and whether outputs are angles, discrete bins, or Cartesian coordinates. Because geometry and calibration matter, those assumptions should be tied closely to the interface.

## Clocking, Reset, and Timing Assumptions

Input channels must be time aligned and correspond to the documented microphone geometry. Reset should clear integration or accumulator state so output estimates restart cleanly.

## Latency, Throughput, and Resource Considerations

Localization can be moderate to heavy depending on microphone count, search-grid size, and whether the design works in the time or frequency domain. Resource use often grows quickly with spatial resolution.

## Verification Strategy

- Compare estimated directions against simulated or recorded array scenarios with known source locations.
- Check geometry interpretation, channel-order assumptions, and confidence output behavior.
- Verify stability and reset behavior when no strong source is present.

## Integration Notes and Dependencies

This block usually follows microphone capture and often precedes beam steering or application logic. Integrators should document the exact array geometry, channel ordering, and sample-rate assumptions, because the module cannot infer them.

## Edge Cases, Failure Modes, and Design Risks

- A microphone-order mismatch can invert or rotate localization results while the numbers still look plausible.
- Insufficient calibration can make the algorithm appear unstable even if the implementation is correct.
- Output confidence may be misinterpreted as absolute certainty unless its meaning is documented.

## Related Modules In This Domain

- microphone_beamformer
- spectrogram_engine
- voice_activity_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Acoustic Localizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
