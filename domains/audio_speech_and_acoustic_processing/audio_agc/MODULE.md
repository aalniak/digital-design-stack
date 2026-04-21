# Audio AGC

## Overview

The audio AGC adjusts signal gain over time so speech or program material remains within a useful dynamic range without constant manual level control. It is the audio-domain counterpart to a more general AGC block, tuned for acoustic content and user-facing behavior.

## Domain Context

Audio, speech, and acoustic modules operate on sampled waveforms where channel layout, frame cadence, perceptual behavior, and latency constraints all matter. In this domain the key documentation topics are sample rate assumptions, frame or block timing, channel conventions, fixed-point scaling, and whether the module is intended for real-time playback, speech analysis, or spatial audio processing.

## Problem Solved

Audio input levels vary widely across microphones, speakers, and environments. Fixed gain either clips loud passages or buries quiet ones. This module applies dynamic gain control with explicit attack, release, and limit behavior so audio pipelines remain usable.

## Typical Use Cases

- Normalizing microphone level before speech processing or recording.
- Maintaining consistent loudness in variable acoustic environments.
- Providing reusable level control in embedded audio products.

## Interfaces and Signal-Level Behavior

- Input side accepts audio samples, often one channel or a small channel group, with valid timing.
- Output side emits gain-adjusted audio and optional gain or level telemetry.
- Control side configures target level, attack and release settings, gain limits, and optional gating policy.

## Parameters and Configuration Knobs

- Sample width, channel count, target level, and detector type.
- Attack and release coefficients, maximum and minimum gain, and saturation policy.
- Peak versus RMS-like detection mode and optional noise-floor management.

## Internal Architecture and Dataflow

The block measures recent signal level, computes a gain update toward the configured target, and applies that gain to the signal with a smoothing law that trades responsiveness against pumping. Audio-specific variants may incorporate hang time, noise gating, or clip prevention. The contract should define whether gain telemetry reflects the applied gain, the requested gain, or a detector state.

## Clocking, Reset, and Timing Assumptions

The meaning of target level depends on the sample scale and channel interpretation, so those conventions should remain visible. Reset should select a safe initial gain that avoids immediate clipping or severe attenuation.

## Latency, Throughput, and Resource Considerations

Audio AGC is moderate in cost and typically runs sample by sample with small additional detector state. Perceptual behavior, latency, and stability matter more than arithmetic throughput.

## Verification Strategy

- Compare level normalization and attack-release behavior against an audio reference model.
- Check gain limits, clipping prevention, and silence or noise-floor behavior.
- Verify reset and runtime parameter updates do not create large audible discontinuities.

## Integration Notes and Dependencies

This module usually sits early in a microphone chain or after some cleanup stages such as echo cancellation. Integrators should document whether the AGC is intended for speech intelligibility, broadcast-like loudness control, or simple capture-level stabilization.

## Edge Cases, Failure Modes, and Design Risks

- An AGC tuned for speech may pump or dull music content, and vice versa.
- If level units are not documented, field tuning becomes guesswork.
- Too much maximum gain can turn background noise into false speech activity downstream.

## Related Modules In This Domain

- gain_block
- voice_activity_detector
- acoustic_echo_canceller

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Audio AGC module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
