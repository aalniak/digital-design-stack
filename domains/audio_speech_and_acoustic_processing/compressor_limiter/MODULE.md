# Compressor or Limiter

## Overview

The compressor or limiter reduces dynamic-range variation or constrains peaks according to configurable threshold and ratio behavior. It is a standard dynamics-processing block for both perceptual audio and protective signal conditioning.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Audio content often contains large level swings or transient peaks that are undesirable for playback, recording, or subsequent processing. A dynamics processor controls those swings, but its threshold, time constants, and gain computer behavior must be explicit to avoid surprises. This module provides that control stage.

## Typical Use Cases

- Protecting outputs from clipping or overload.
- Reducing dynamic range for intelligibility or consumer playback.
- Providing reusable dynamics control in embedded audio chains.

## Interfaces and Signal-Level Behavior

- Input side accepts audio samples and optional sidechain or detector input.
- Output side emits processed audio and may expose gain reduction or detector telemetry.
- Control side configures threshold, ratio, attack, release, and make-up gain or limiter mode.

## Parameters and Configuration Knobs

- Sample width, detector type, threshold precision, ratio representation, and time-constant precision.
- Lookahead depth, sidechain mode, and saturation policy.
- Stereo or multichannel link behavior and runtime parameter update rules.

## Internal Architecture and Dataflow

The block measures input level or sidechain level, computes a gain reduction according to the configured dynamics curve, smooths that reduction with attack and release behavior, and applies the gain to the audio path. Limiter modes may use stricter peak handling and lookahead. The contract should clarify whether the detector is peak-like, RMS-like, or sidechain driven and how multichannel linking works.

## Clocking, Reset, and Timing Assumptions

Thresholds and ratios are meaningful only in the chosen sample scale and detector convention, so those assumptions should stay visible. Reset should initialize gain reduction smoothly or to unity to avoid startup clicks.

## Latency, Throughput, and Resource Considerations

Dynamics processing is moderate in cost and usually easy to sustain at audio sample rates, but lookahead and multichannel linking add buffering and control complexity. Perceptual quality matters more than arithmetic throughput.

## Verification Strategy

- Compare gain reduction and output level against a reference dynamics processor on several test signals.
- Check attack-release transients, limiter mode, and sidechain behavior.
- Verify runtime parameter changes and reset behavior do not create unwanted clicks or jumps.

## Integration Notes and Dependencies

This block often sits near final playback or speech-conditioning paths, so its loudness and peak-handling semantics should be documented for system tuning. Integrators should also note whether gain telemetry is needed for UI or metering.

## Edge Cases, Failure Modes, and Design Risks

- Poor detector or time-constant choices can pump audibly even if the arithmetic is correct.
- If stereo linking is inconsistent, the image can wander under compression.
- Lookahead latency may accumulate in ways that matter for monitoring and AV sync.

## Related Modules In This Domain

- gain_block
- audio_agc
- noise_gate

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Compressor or Limiter module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
