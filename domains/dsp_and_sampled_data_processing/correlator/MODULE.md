# Correlator

## Overview

The correlator measures similarity between an incoming signal and a reference sequence, producing a response that is useful for detection, synchronization, ranging, and feature extraction. It is one of the core computational primitives in communication, radar, sonar, and timing systems.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Detection and synchronization often depend on finding where a known pattern aligns with a noisy received signal. Ad hoc implementations of that operation vary in normalization, lag handling, and numeric precision. This module provides a consistent correlation engine with a clear contract for reference storage, accumulation, and output interpretation.

## Typical Use Cases

- Detecting preambles, pilot sequences, or known codes in communication receivers.
- Performing matched-filter-like operations for ranging or pulse compression.
- Generating similarity scores for feature detection in sampled-data research pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts real or complex sample streams and may support frame markers that reset the lag window.
- Reference side loads a template sequence or coefficient set, either statically or at runtime.
- Output side emits correlation scores, peak indicators, or lag metadata depending on the configured mode.

## Parameters and Configuration Knobs

- Reference length, sample width, complex versus real mode, and output accumulation width.
- Sliding, block, or lag-scan operating mode plus normalization and peak-detection options.
- Coefficient reload behavior and whether conjugation is automatic for complex references.

## Internal Architecture and Dataflow

A correlator generally multiplies incoming samples by stored reference coefficients, accumulates the products over the chosen window, and emits a score associated with a particular lag or frame position. Sliding correlators reuse partial sums across overlapping windows, while block correlators recompute each frame independently. For complex data, conjugation and accumulator precision are crucial to preserve the intended matched-filter response.

## Clocking, Reset, and Timing Assumptions

The module contract should state exactly how lag indexing works and whether outputs are normalized or raw energy dependent. Reset and reference reload policy need to prevent half-updated templates from mixing with active accumulation windows.

## Latency, Throughput, and Resource Considerations

Correlation is multiply-accumulate intensive, so throughput depends on whether the design is fully parallel, time-multiplexed, or uses FFT-based methods externally. Resource cost scales with reference length and data complexity.

## Verification Strategy

- Compare detection peaks and lag outputs against a floating-point reference across noisy and noiseless scenarios.
- Check complex conjugation, normalization, and accumulator sizing with strong signals.
- Verify behavior when references are reloaded or frames are shorter than the expected correlation window.

## Integration Notes and Dependencies

Correlators often feed detectors, synchronizers, and trackers, so the statistical meaning of the score should be documented. Integrators should also know whether latency is fixed, frame dependent, or lag dependent.

## Edge Cases, Failure Modes, and Design Risks

- A mistaken lag convention can shift detections consistently while leaving response shape otherwise plausible.
- Accumulator overflow can flatten peaks and ruin detection sensitivity in ways that resemble algorithmic noise.
- If reference updates are not atomic, transient false peaks may appear during coefficient changes.

## Related Modules In This Domain

- beamformer
- matched_filter
- agc_block

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Correlator module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
