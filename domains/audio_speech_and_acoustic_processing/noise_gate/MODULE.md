# Noise Gate

## Overview

The noise gate attenuates or mutes audio when the signal level falls below a configured threshold, reducing background noise during silent or near-silent periods. It is a simple dynamics processor commonly used in voice and instrument chains.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Background noise and idle-room sound can dominate signals when the desired source is absent. A noise gate suppresses that low-level content, but its threshold, hysteresis, and release behavior must be explicit to avoid chopping desired material. This module packages that gating behavior.

## Typical Use Cases

- Suppressing room noise in microphone signals during silence.
- Reducing idle-path hiss or bleed in multichannel audio systems.
- Providing reusable low-level gating before speech analysis or playback.

## Interfaces and Signal-Level Behavior

- Input side accepts audio samples and optional sidechain or detector input.
- Output side emits gated audio and optional open or closed status.
- Control side sets threshold, hysteresis, attack, release, and attenuation depth.

## Parameters and Configuration Knobs

- Sample width, threshold precision, attack-release timing, and attenuation mode.
- Hysteresis depth, sidechain support, and full-mute versus partial-attenuation behavior.
- Runtime parameter updates and channel-linking policy.

## Internal Architecture and Dataflow

The block measures signal level, applies threshold and hysteresis logic to determine gate state, and smooths transitions with attack and release timing to reduce clicks. Some designs mute fully, while others apply a configurable attenuation floor. The contract should define which signal the detector observes and how state transitions are timed.

## Clocking, Reset, and Timing Assumptions

Threshold meaning depends on sample scale and detector convention, so those assumptions should remain visible. Reset should initialize the gate state predictably, typically closed or with a documented hold state.

## Latency, Throughput, and Resource Considerations

Noise gating is moderate in cost and easy to sustain at audio rates. Perceptual transition quality matters much more than arithmetic complexity.

## Verification Strategy

- Compare gate opening and closing behavior against a dynamics reference on speech-like and noise-only material.
- Check hysteresis, attack-release smoothing, and sidechain behavior if supported.
- Verify reset and parameter changes do not create strong audible clicks.

## Integration Notes and Dependencies

This block is often placed before AGC, VAD, or playback stages, and its placement changes behavior significantly. Integrators should document whether the gate is intended as hard suppression or gentle noise-floor cleanup.

## Edge Cases, Failure Modes, and Design Risks

- Thresholds that are too aggressive can clip speech onsets or tails.
- If hysteresis is too small, the gate may chatter on noisy inputs.
- A mismatch between detector path and processed path can make tuning counterintuitive.

## Related Modules In This Domain

- compressor_limiter
- voice_activity_detector
- audio_agc

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Noise Gate module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
