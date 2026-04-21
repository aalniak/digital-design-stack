# Channelizer

## Overview

The channelizer splits a wideband input stream into multiple narrower subbands so later processing can focus only on frequencies of interest. It is a common front end in radios, radar receivers, acoustic analyzers, and spectrum-monitoring systems.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Wideband sampled streams often contain more spectrum than any one downstream algorithm needs. Processing everything at full rate wastes compute and memory bandwidth. A channelizer reorganizes the signal into subchannels, usually with decimation, making frequency-selective processing practical.

## Typical Use Cases

- Breaking a wide receive band into subchannels for parallel demodulation or detection.
- Feeding subband beamformers or feature extractors in array-processing pipelines.
- Supporting spectrum analysis or signal monitoring across many narrow frequency bins.

## Interfaces and Signal-Level Behavior

- Input side accepts a full-rate real or complex sample stream.
- Output side emits either time-multiplexed or parallel subchannel samples plus channel indices or framing markers.
- Control side configures enabled channels, decimation behavior, and optional coefficient-bank selection.

## Parameters and Configuration Knobs

- Number of channels, prototype-filter coefficient set, input format, and output packing style.
- Decimation ratio, polyphase structure, FFT size if applicable, and coefficient width.
- Support for runtime channel enable masks or per-channel gain normalization.

## Internal Architecture and Dataflow

Many channelizers use a polyphase filter bank followed by an FFT or structured modulation stage to produce evenly spaced subbands efficiently. Others implement a smaller bank of individually tuned filters. The core challenge is keeping time and frequency indexing consistent so each output sample is traceable to the correct subchannel and decimated time instant.

## Clocking, Reset, and Timing Assumptions

The module contract should specify whether output channels are critically sampled, oversampled, or sparsely enabled. Reset and framing behavior need special care because downstream blocks often assume channel ordering restarts deterministically at frame boundaries.

## Latency, Throughput, and Resource Considerations

Channelizers trade front-end complexity for downstream savings. Resource cost grows with channel count and prototype filter quality, but efficient polyphase structures can be far cheaper than many independent filters.

## Verification Strategy

- Compare subchannel frequency responses and channel ordering against a reference model.
- Verify framing and channel index behavior across resets and gaps in input validity.
- Check leakage and aliasing performance with tones near channel boundaries.

## Integration Notes and Dependencies

Channelizers often feed per-channel AGC, detectors, or demodulators. Integration should define the meaning of each channel index, output sample timing, and whether disabled channels still consume bandwidth in the output interface.

## Edge Cases, Failure Modes, and Design Risks

- Incorrect channel ordering can silently route signals to the wrong downstream algorithm.
- Prototype filter scaling errors may create uneven passband gain across channels.
- If decimation framing is unclear, later blocks may combine samples from different channel epochs.

## Related Modules In This Domain

- fft_engine
- cic_decimator
- beamformer

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Channelizer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
