# Digital Mixer

## Overview

The digital mixer multiplies an input sample stream by a sinusoidal or complex exponential reference so signal energy is shifted to a new center frequency. It is a foundational building block for upconversion, downconversion, quadrature generation, and modulation research.

## Domain Context

DSP and sampled-data processing modules operate on numerically structured streams where timing regularity, coefficient interpretation, and spectral behavior matter as much as raw logic correctness. In this domain the most important documentation themes are fixed-point scaling, streaming cadence, filter state management, latency, and how algorithmic intent maps onto hardware structure.

## Problem Solved

Frequency translation is required in many sampled-data systems, but re-implementing the multiply and phase-control path repeatedly creates inconsistent conventions for I and Q signs, scaling, and latency. This module provides a reusable mixing primitive with a documented frequency and numeric contract.

## Typical Use Cases

- Shifting a received band to baseband in a DDC path.
- Upconverting baseband or IF content before interpolation and DAC playback.
- Generating quadrature products for measurement or lock-in style analysis.

## Interfaces and Signal-Level Behavior

- Input side accepts real or complex samples with normal streaming valid timing.
- Reference side is usually driven by an NCO or external complex carrier stream.
- Output side emits mixed real or complex products and may provide saturation or phase-control status.

## Parameters and Configuration Knobs

- Sample and coefficient widths, real versus complex input mode, and multiplier precision.
- Scaling mode, output rounding, and optional saturation or truncation behavior.
- Carrier source selection and support for runtime phase or frequency changes when coupled to an internal oscillator.

## Internal Architecture and Dataflow

For complex mixing the block multiplies the signal by a complex exponential and accumulates the real and imaginary partial products into translated I and Q outputs. For real mixing the design may emit an expanded sideband pair or a real product only, depending on how the chain is built. Precision planning matters because the mixer is often followed by filters that assume a known gain and image structure.

## Clocking, Reset, and Timing Assumptions

The frequency reference must remain phase coherent with system expectations, especially when several channels are mixed in parallel. Reset should define the starting phase behavior clearly so deterministic simulations and synchronized multi-channel systems can align their outputs.

## Latency, Throughput, and Resource Considerations

A digital mixer can sustain one sample per cycle in fully parallel form, but complex mode consumes more multipliers and routing than real mode. Resource cost is set mostly by multiplier width and by whether carrier generation is integrated or external.

## Verification Strategy

- Compare translated tone locations and amplitude against a numerical reference model for several carrier frequencies.
- Check complex sign convention, image placement, and scaling in both real and complex modes.
- Verify phase-reset behavior and runtime tuning updates when driven by an NCO.

## Integration Notes and Dependencies

Mixers normally pair with oscillators and filters, so the surrounding chain should document whether the positive-frequency convention is lower-sideband or upper-sideband relative to the sample representation. Integrators should also keep track of any gain introduced by coefficient normalization.

## Edge Cases, Failure Modes, and Design Risks

- A simple I or Q sign swap can invert sideband orientation and break later demodulation.
- Truncating mixed products too early can bury weak signals in quantization noise.
- If the carrier phase convention is not consistent across channels, beamforming or coherent processing degrades badly.

## Related Modules In This Domain

- numerically_controlled_oscillator
- ddc_chain
- duc_chain

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Digital Mixer module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
