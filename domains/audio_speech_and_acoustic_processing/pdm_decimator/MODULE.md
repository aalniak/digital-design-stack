# PDM Decimator

## Overview

The PDM decimator converts oversampled pulse-density microphone data into lower-rate PCM audio suitable for standard audio processing. It is one of the earliest digital stages in many microphone acquisition chains.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

PDM microphones emit a high-rate single-bit stream that is transport-efficient but not directly useful for ordinary audio DSP. A decimation path is required to recover PCM while suppressing out-of-band quantization noise. This module provides that conversion step.

## Typical Use Cases

- Capturing audio from PDM microphones into PCM processing pipelines.
- Serving as the front end of voice-input or acoustic-sensing systems.
- Providing reusable microphone-ingress conversion in embedded audio products.

## Interfaces and Signal-Level Behavior

- Input side accepts one or more PDM bitstreams and associated clocks or strobes.
- Output side emits PCM samples with channel framing and valid timing at the decimated rate.
- Control side configures decimation ratio, filter profile, and optional channel enable or gain trim.

## Parameters and Configuration Knobs

- PDM clock ratio, PCM output width, channel count, and filter structure.
- Decimation factor, high-pass or DC-removal options, and scaling policy.
- Clock-domain handling and optional stereo interleave support.

## Internal Architecture and Dataflow

The module usually combines CIC-like or multistage decimation with compensation filtering to remove shaped quantization noise and produce usable PCM audio. It may also include DC removal or channel-specific scaling. The contract should define whether the output is left-justified PCM, signed audio samples, or another format, and how channel timing is emitted.

## Clocking, Reset, and Timing Assumptions

The design assumes a documented PDM clock rate and channel multiplexing convention, if any. Reset should clear decimator state so PCM output restarts from a clean filter history.

## Latency, Throughput, and Resource Considerations

The high-rate front end of the decimator can be timing sensitive, though the arithmetic itself is modest. Resource use depends on channel count, decimation ratio, and filter quality.

## Verification Strategy

- Compare PCM output against a software PDM-decimation reference using synthetic and recorded bitstreams.
- Check channel ordering, scaling, and high-pass or DC-removal behavior.
- Verify reset and startup transients at the beginning of capture.

## Integration Notes and Dependencies

This block sits at the ingress of microphone processing and should be documented together with sample-rate assumptions and any later beamforming or VAD pipeline. Integrators should also note whether output gain is already calibrated or still raw.

## Edge Cases, Failure Modes, and Design Risks

- An incorrect channel-multiplexing convention can swap or corrupt microphones subtly.
- Insufficient filtering can leave shaped PDM noise in-band and degrade later speech algorithms.
- Startup transients may contaminate early frames if downstream logic assumes immediate valid speech content.

## Related Modules In This Domain

- i2s_rx_tx
- microphone_beamformer
- audio_agc

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the PDM Decimator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
