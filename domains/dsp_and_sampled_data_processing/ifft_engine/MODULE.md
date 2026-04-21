# IFFT Engine

## Overview

The IFFT engine computes the inverse discrete Fourier transform efficiently and is used to synthesize time-domain signals from spectral or subcarrier-domain representations. It is a natural partner to the FFT engine in modulation, waveform synthesis, and spectral-domain processing systems.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Many systems create or manipulate signals in the frequency domain but must emit or store them as time-domain samples. An efficient inverse transform is therefore needed, and it must match the scaling, ordering, and framing conventions of the surrounding architecture. This module provides that reusable inverse transform primitive.

## Typical Use Cases

- Synthesizing OFDM or multitone waveforms from subcarrier bins.
- Reconstructing time-domain signals after frequency-domain processing or filtering.
- Serving as the inverse counterpart to a repository-wide FFT contract.

## Interfaces and Signal-Level Behavior

- Input side accepts block-framed complex bins in a documented order.
- Output side emits time-domain samples with explicit frame boundaries and scaling semantics.
- Control side selects transform size, scaling schedule, and optional ordering adaptations.

## Parameters and Configuration Knobs

- Transform length, twiddle precision, internal scaling schedule, and output ordering.
- Streaming or burst architecture, runtime length changes, and complex data width.
- Optional block floating-point exponent reporting or normalization style.

## Internal Architecture and Dataflow

The internal structure mirrors a forward FFT closely, with staged butterflies and twiddle operations arranged to implement the inverse transform convention chosen by the design. The documentation must state whether the engine uses mathematical inverse normalization internally or expects normalization outside, because that choice changes signal amplitude directly.

## Clocking, Reset, and Timing Assumptions

Input bins must follow the expected ordering and represent a complete block for the selected size. Reset and block-abort behavior should clear any partially assembled inverse transform so the next waveform frame starts cleanly.

## Latency, Throughput, and Resource Considerations

Like the forward FFT, an IFFT can be built for high streaming throughput or lower-area burst behavior. Resource use depends on transform length, complex multiplier count, and any internal reorder logic.

## Verification Strategy

- Check round-trip FFT followed by IFFT behavior against a numerical reference with known normalization.
- Verify bin ordering, scaling, and output framing at several transform sizes.
- Exercise incomplete-frame and reset behavior so invalid partial outputs are not emitted.

## Integration Notes and Dependencies

IFFTs often feed cyclic-prefix logic, waveform buffers, or DAC chains. Integrators should record the normalization and bin-order contract explicitly so waveform generators and spectral-domain tools remain compatible.

## Edge Cases, Failure Modes, and Design Risks

- A normalization mismatch between FFT and IFFT can create persistent amplitude errors that look like gain issues elsewhere.
- Incorrect bin ordering can synthesize a valid-looking but wrong waveform.
- Frame slippage at the inverse transform boundary can corrupt many emitted samples at once.

## Related Modules In This Domain

- fft_engine
- window_generator
- duc_chain

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the IFFT Engine module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
