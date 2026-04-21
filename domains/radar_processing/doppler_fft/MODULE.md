# Doppler FFT

## Overview

The Doppler FFT transforms coherent returns across a burst of chirps or pulses to reveal radial velocity information. It is the temporal-frequency half of range-Doppler processing.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Velocity information is encoded in coherent phase progression across chirps or pulses, not in one sweep alone. A Doppler transform extracts that information, but its framing and sign convention must be exact to support downstream detection and tracking. This module packages that transform stage.

## Typical Use Cases

- Computing velocity bins from coherent chirp sequences.
- Building range-Doppler maps in FMCW and pulse-Doppler systems.
- Providing reusable temporal spectral processing in radar pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent samples organized by chirp or pulse index for each range cell.
- Output side emits Doppler bins or spectra plus associated range-cell context.
- Control side configures FFT size, windowing, and output ordering.

## Parameters and Configuration Knobs

- Pulse or chirp count, sample precision, FFT size, and output ordering.
- Windowing profile, zero-padding support, and velocity-bin orientation convention.
- Runtime mode selection and frame-boundary semantics.

## Internal Architecture and Dataflow

The block windows the slow-time sequence for each range cell and applies an FFT across chirps or pulses, producing a Doppler spectrum whose bins correspond to radial velocity hypotheses. The contract should define whether bins are shifted around zero Doppler, what sign convention corresponds to approaching or receding motion, and how incomplete bursts are handled.

## Clocking, Reset, and Timing Assumptions

Input chirp ordering and coherence must match the documented burst structure exactly, and any MTI or clutter suppression assumptions should be explicit. Reset should clear burst assembly state before a new coherent frame begins.

## Latency, Throughput, and Resource Considerations

Doppler processing is moderate in cost and often reused across many range cells, making memory organization and throughput important. Resource use depends on burst length and whether several cells are processed in parallel.

## Verification Strategy

- Compare Doppler spectra against a reference FFT for synthetic moving targets and stationary clutter.
- Check bin ordering, sign convention, and windowing behavior.
- Verify burst-boundary resets and incomplete-burst handling.

## Integration Notes and Dependencies

This block usually follows range FFT or dechirped buffering and precedes CFAR and target reporting, so the resulting velocity-bin convention should be documented with those consumers. Integrators should also note whether zero-Doppler centering is internal or left to later stages.

## Edge Cases, Failure Modes, and Design Risks

- A velocity-sign mismatch can invert approaching and receding targets without changing map magnitude.
- Burst assembly errors may smear energy across Doppler bins in ways that look like poor SNR.
- If zero-Doppler shifting is undocumented, tracker and display layers may disagree on bin indexing.

## Related Modules In This Domain

- range_doppler_builder
- mti_filter
- cfar_detector

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Doppler FFT module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
