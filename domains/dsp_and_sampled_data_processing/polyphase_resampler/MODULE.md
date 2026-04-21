# Polyphase Resampler

## Overview

The polyphase resampler changes sample rate by rational or programmable factors using a bank of phase-selected FIR responses. It is the reusable answer when a simple power-of-two rate change is not enough and high-quality interpolation or decimation is still required.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Real systems often need to bridge incompatible sample rates that are not neat powers of two. Naive interpolation followed by filtering is too expensive, and ad hoc resamplers frequently obscure phase indexing and timing behavior. This module implements the structured polyphase approach so rate change stays efficient and well documented.

## Typical Use Cases

- Bridging sample rates between sensors, codecs, and communications subsystems.
- Implementing rational resampling in SDR, audio, or instrumentation pipelines.
- Supporting high-quality timing correction or fractional-rate adaptation in research systems.

## Interfaces and Signal-Level Behavior

- Input side accepts a sample stream with regular valid timing.
- Control side sets the interpolation and decimation ratio or phase-step policy and may load coefficient banks.
- Output side emits resampled data with valid pulses that reflect the new sample cadence.

## Parameters and Configuration Knobs

- Interpolation and decimation factors, coefficient-bank structure, and sample or coefficient width.
- Internal phase-accumulator precision, output rounding, and buffer depth.
- Runtime ratio change support and whether coefficients are static or reloadable.

## Internal Architecture and Dataflow

A polyphase resampler decomposes the prototype filter into several phase branches and chooses the correct branch according to the evolving input-output time relationship. This lets the design compute only the phase that contributes to each output sample instead of evaluating an oversized full-rate filter. The module contract must make output valid timing explicit because the output cadence is not always one sample per input or vice versa.

## Clocking, Reset, and Timing Assumptions

Correct behavior depends on the ratio and coefficient design being matched to the intended signal bandwidth and stopband requirements. Reset and ratio changes should reinitialize phase selection cleanly so one output sample is never generated from stale timing state.

## Latency, Throughput, and Resource Considerations

Polyphase resamplers are more efficient than naive upsample-then-filter structures for nontrivial ratios, but they still require significant multiplier and buffer resources for sharp responses. Throughput depends on how many phases and taps are computed in parallel.

## Verification Strategy

- Compare resampled outputs and frequency response against a floating-point model for several rational ratios.
- Check output timing and valid pulse placement around resets and ratio changes.
- Verify coefficient-bank indexing so the correct phase response is used for each generated sample.

## Integration Notes and Dependencies

These blocks often sit between otherwise well-defined sample domains, so the surrounding system should document the exact input and output rates rather than assuming they can be inferred later. Integrators should also capture the latency introduced by the prototype filter and phase pipeline.

## Edge Cases, Failure Modes, and Design Risks

- A phase-indexing error can produce subtle imaging and timing drift rather than catastrophic failure.
- If ratio changes are applied midstream without a handoff policy, transient artifacts may be large.
- Coefficient sets designed for the wrong bandwidth can make the resampler look numerically fine while damaging spectral purity.

## Related Modules In This Domain

- fir_filter
- halfband_fir_filter
- window_generator

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Polyphase Resampler module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
