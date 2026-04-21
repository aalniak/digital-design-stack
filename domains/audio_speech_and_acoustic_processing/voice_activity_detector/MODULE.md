# Voice Activity Detector

## Overview

The voice activity detector classifies analysis frames or segments as speech-active or not based on level, spectral, or feature cues. It is a decision block that gates later speech processing and communication logic.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Speech pipelines often need to know when speech is present so they can trigger recording, beamforming focus, wake-word front ends, or network transmission. A VAD provides that decision, but its frame semantics and confidence outputs must be explicit. This module packages that gating logic.

## Typical Use Cases

- Suppressing uplink transmission during silence.
- Gating speech-feature extraction or keyword-spotting systems.
- Providing reusable speech-presence estimation in audio products and research pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts audio frames, frame features, or detector statistics depending on the configured mode.
- Output side emits speech-active flags, confidence, and optional hangover or transition status.
- Control side configures thresholds, frame size, hangover time, and decision mode.

## Parameters and Configuration Knobs

- Input representation mode, frame length, threshold precision, and confidence width.
- Hangover policy, smoothing, and optional noise-estimation support.
- Runtime parameter updates and output cadence.

## Internal Architecture and Dataflow

The detector evaluates one or more cues such as energy, spectral shape, or learned statistics over each analysis frame and then applies hysteresis or hangover logic to avoid unstable chatter. The documentation should state whether outputs are frame-aligned labels, edge events, or both, and whether the detector expects raw audio or precomputed features.

## Clocking, Reset, and Timing Assumptions

The meaning of a speech-active decision depends on frame size, sample rate, and upstream conditioning such as AGC or noise suppression, so those assumptions should remain visible. Reset should initialize any hangover or noise-floor state deterministically.

## Latency, Throughput, and Resource Considerations

VAD logic is usually moderate in cost and frame-rate driven rather than sample-rate dominated. Latency is mostly the analysis frame and hangover choice.

## Verification Strategy

- Compare speech-active decisions against a reference VAD on speech, noise, and mixed recordings.
- Check hangover, confidence output, and reset behavior.
- Verify operation in each supported input-representation mode.

## Integration Notes and Dependencies

This block often sits near microphone conditioning, feature extraction, and communication gating, so its frame cadence and confidence semantics should be documented for neighboring modules. Integrators should also record whether it is tuned for low false alarms or low misses.

## Edge Cases, Failure Modes, and Design Risks

- A VAD tuned for one noise environment may behave poorly in another even if the implementation is correct.
- Frame-length changes affect both latency and detection behavior significantly.
- If hangover semantics are vague, downstream systems may misinterpret speech-start and speech-end timing.

## Related Modules In This Domain

- audio_agc
- mel_filter_bank
- acoustic_echo_canceller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Voice Activity Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
