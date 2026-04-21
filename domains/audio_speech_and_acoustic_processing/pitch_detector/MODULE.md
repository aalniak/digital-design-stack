# Pitch Detector

## Overview

The pitch detector estimates the fundamental frequency or pitch of a voiced audio signal, typically speech or musical content. It is a feature-analysis block rather than a playback processor.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Pitch is a central descriptor for speech prosody, voicing, and musical analysis, but it is not directly visible in the raw waveform without an estimator. This module provides that estimation stage with an explicit update and confidence contract.

## Typical Use Cases

- Tracking speech pitch in voice interfaces and analysis tools.
- Extracting fundamental frequency from monophonic musical signals.
- Providing reusable pitch features to higher-level audio or speech models.

## Interfaces and Signal-Level Behavior

- Input side accepts audio samples or preconditioned frames.
- Output side emits pitch estimates, voicing flags, and optional confidence metrics.
- Control side configures search range, frame size, and detection algorithm mode.

## Parameters and Configuration Knobs

- Sample width, analysis frame length, search-range configuration, and estimator precision.
- Autocorrelation versus other supported method choices, output update cadence, and confidence representation.
- Runtime parameter updates and optional preemphasis or conditioning enable.

## Internal Architecture and Dataflow

The detector analyzes recent signal structure to identify the most plausible fundamental period or frequency, often using autocorrelation-like or spectral methods. The output may be frame based, block based, or overlap updated. The contract should state whether the block emits Hz-like frequency codes, period estimates, or quantized bins, and how unvoiced frames are represented.

## Clocking, Reset, and Timing Assumptions

Pitch detection is meaningful only over a documented signal band and frame length, so sample rate and preconditioning assumptions matter. Reset should clear frame history and confidence state explicitly.

## Latency, Throughput, and Resource Considerations

Pitch detection is moderate in cost and usually runs at frame rate rather than every sample. Accuracy, latency, and voicing robustness matter more than raw throughput.

## Verification Strategy

- Compare estimated pitch against a reference detector on voiced speech and simple tonal inputs.
- Check unvoiced or noisy-frame behavior and confidence outputs.
- Verify frame update cadence and reset handling.

## Integration Notes and Dependencies

This block often follows conditioning such as AGC or noise suppression and may feed speech features or control logic. Integrators should document whether pitch outputs are intended for human interpretation, ML features, or control loops.

## Edge Cases, Failure Modes, and Design Risks

- Different pitch conventions such as period versus frequency can be mixed up easily.
- Noisy or harmonic-rich material may produce plausible but wrong octave estimates unless confidence semantics are understood.
- Frame-size changes alter both latency and estimator behavior significantly.

## Related Modules In This Domain

- voice_activity_detector
- spectrogram_engine
- mfcc_extractor

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Pitch Detector module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
