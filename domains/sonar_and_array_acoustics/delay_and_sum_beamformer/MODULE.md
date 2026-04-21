# Delay-and-Sum Beamformer

## Overview

Delay-and-Sum Beamformer steers one or more receive beams by applying programmable channel delays and summing aligned hydrophone samples. It is the foundational spatial front end for many passive and active sonar systems because it converts raw array data into directionally selective streams with a simple and interpretable signal model.

## Domain Context

Delay-and-sum beamforming is the canonical spatial filtering stage for hydrophone arrays. It applies per-channel time or phase alignment so energy from a chosen look direction adds coherently while off-axis noise, shipping noise, and interference add less constructively.

## Problem Solved

Without beamforming, downstream detectors operate on omnidirectional sensor mixtures and lose directional gain. In underwater environments with strong ambient noise and multipath, spatial selectivity is often the difference between a useful contact and an unmanageable noise floor.

## Typical Use Cases

- Forming a small bank of steerable beams for passive bearing estimation.
- Beamforming active returns before matched filtering or vice versa, depending on system latency and compute budget.
- Supporting towed arrays, hull arrays, or laboratory hydrophone arrays with fixed geometry tables.
- Producing broadside and endfire comparison beams for calibration and array-health checks.

## Interfaces and Signal-Level Behavior

- Input is typically a frame containing simultaneous samples from all enabled hydrophone channels.
- Control interfaces load delay tables, steering-angle selections, sound-speed assumptions, and per-channel weights or mutes.
- Outputs may expose one or several beam streams, each with valid markers, beam identifiers, and optional power summaries.
- Status signals often include delay-table-active, configuration-ready, and overflow indicators for the summer path.

## Parameters and Configuration Knobs

- Maximum channel count, number of simultaneously produced beams, and supported delay range.
- Integer versus fractional delay support, along with interpolation order for fractional steering.
- Per-channel weight width and accumulator width for coherent summation.
- Geometry-table depth and whether delay sets can be double-buffered for scan scheduling.

## Internal Architecture and Dataflow

The module generally contains channel buffers, a delay-selection fabric, optional fractional interpolation, apodization weights, and one or more summation trees. In sonar, the architecture must honor array geometry and sound-speed assumptions explicitly because steering error translates directly into bearing bias and degraded sidelobe control.

## Clocking, Reset, and Timing Assumptions

Inputs must represent time-aligned channel snapshots from the hydrophone interface or an equivalent framing layer. The beamformer assumes a known array geometry and an operating sound-speed model that is good enough for the intended frequency band. Reset should clear partial buffer history and prevent mixed steering tables during a beam transition.

## Latency, Throughput, and Resource Considerations

Cost grows quickly with channel count, beam count, and fractional-delay fidelity. Integer-delay beamformers are lighter but less accurate at higher frequencies. Throughput must sustain one multichannel frame per sample interval, and latency should be deterministic so downstream trackers can align beam outputs with timestamps and platform motion data.

## Verification Strategy

- Use synthetic plane waves from known bearings and confirm the chosen beam peaks at the expected steering angle.
- Sweep steering tables to measure sidelobe behavior and ensure delay quantization matches the documented model.
- Check mute, failed-channel, and weight-update cases so degraded arrays fail gracefully rather than catastrophically.
- Validate beam timestamping and latency consistency when multiple beams are emitted in parallel.

## Integration Notes and Dependencies

Delay-and-Sum Beamformer usually consumes Hydrophone Frontend Interface frames and may feed passive detectors, spectrogram engines, matched filters, or bearing trackers. It should integrate with array calibration data, navigation estimates for moving platforms, and environmental models when sound speed or geometry compensation is adaptive.

## Edge Cases, Failure Modes, and Design Risks

- Small channel-delay errors can create large bearing bias, especially on long apertures.
- Updating steering tables mid-frame can produce nonphysical beam artifacts unless configuration is double-buffered.
- A failed or noisy sensor can dominate sidelobes if mute and weighting policies are not enforced.

## Related Modules In This Domain

- hydrophone_frontend_interface
- array_calibration
- bearing_estimator
- tdoa_estimator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Delay-and-Sum Beamformer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
