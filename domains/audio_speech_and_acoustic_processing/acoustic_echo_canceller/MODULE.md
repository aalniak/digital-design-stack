# Acoustic Echo Canceller

## Overview

The acoustic echo canceller estimates and removes echoes of a known playback or far-end signal from a microphone stream so near-end speech or local acoustic content can be recovered more cleanly. It is a core real-time speech and conferencing primitive.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

When loudspeakers and microphones share an environment, the microphone contains delayed and filtered copies of the played-back audio that interfere with local speech. Removing that echo requires an adaptive estimate of the acoustic path and careful real-time signal alignment. This module packages that cancellation path explicitly.

## Typical Use Cases

- Hands-free voice or conferencing systems that must suppress far-end playback echo.
- Smart-speaker and intercom pipelines that need clean near-end speech capture.
- Research systems exploring adaptive acoustic path cancellation in hardware.

## Interfaces and Signal-Level Behavior

- Reference side accepts the playback or far-end signal used to model echo.
- Microphone side accepts the captured acoustic signal to be cleaned.
- Output side emits the residual near-end signal plus optional adaptation or convergence status.

## Parameters and Configuration Knobs

- Sample width, adaptive-filter length, block versus sample update mode, and channel count.
- Step-size or adaptation-control precision, double-talk handling policy, and latency alignment depth.
- Support for fixed acoustic path models versus fully adaptive cancellation.

## Internal Architecture and Dataflow

The module aligns the playback reference with the microphone capture, filters the reference through an adaptive model of the acoustic path, and subtracts the estimated echo from the microphone stream. Practical implementations also include logic to freeze or slow adaptation during double-talk or unstable conditions. The contract should state whether the output is intended for direct listening, further speech processing, or both.

## Clocking, Reset, and Timing Assumptions

Cancellation quality depends on signal alignment, room dynamics, and adaptation policy, so the documentation should be honest about environmental assumptions. Reset should clear adaptive state and define whether the module starts from silence, bypass, or a previously loaded profile.

## Latency, Throughput, and Resource Considerations

Echo cancellation is one of the heavier audio blocks because it combines adaptive filtering, buffering, and control logic. Latency and convergence matter at least as much as raw throughput.

## Verification Strategy

- Compare residual echo suppression against a software reference on known playback-plus-mic scenarios.
- Check convergence, double-talk handling, and alignment behavior under several delays.
- Verify reset and adaptation-freeze transitions do not inject strong artifacts into the output.

## Integration Notes and Dependencies

This block usually sits early in a microphone chain and depends on clean access to the playback reference and accurate relative delay. Integrators should document the latency from playback source to acoustic capture path because the canceller depends on that alignment.

## Edge Cases, Failure Modes, and Design Risks

- Poor reference-to-microphone alignment can make a correct adaptive core appear ineffective.
- Double-talk logic that is too aggressive can stall convergence, while logic that is too weak can corrupt speech.
- If residual output semantics are not clear, downstream speech models may be tuned for the wrong signal stage.

## Related Modules In This Domain

- microphone_beamformer
- voice_activity_detector
- audio_agc

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Acoustic Echo Canceller module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
