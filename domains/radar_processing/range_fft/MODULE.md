# Range FFT

## Overview

The range FFT transforms coherent fast-time radar samples into discrete range bins, providing the first explicit range-domain representation used by many later radar stages. It is a foundational spectral stage in FMCW and pulse-style pipelines.

## Domain Context

Radar-processing modules convert coherent sampled returns into range, velocity, angle, and target-level products. In this domain the critical documentation topics are chirp and pulse framing, coherent phase conventions, array geometry assumptions, range-Doppler indexing, and whether each block preserves or destroys phase information needed by later stages.

## Problem Solved

Delay information is buried in the phase progression of fast-time samples and is not directly useful to detectors or trackers. A reusable transform stage is needed so the rest of the radar chain can work with consistent range bins rather than waveform-specific sample windows.

## Typical Use Cases

- Computing range bins from dechirped FMCW sweeps.
- Transforming fast-time data before Doppler processing or map building.
- Providing reusable range conversion in coherent radar pipelines.

## Interfaces and Signal-Level Behavior

- Input side accepts coherent fast-time sample blocks aligned to chirp or pulse boundaries.
- Output side emits complex or reduced range-bin data with explicit block-valid timing.
- Control side configures FFT size, windowing, output ordering, and waveform profile selection.

## Parameters and Configuration Knobs

- Fast-time block length, FFT size, sample precision, and output representation.
- Window profile, zero padding, bin-order policy, and runtime profile support.
- Complex versus real input mode and scaling conventions.

## Internal Architecture and Dataflow

The block windows each fast-time sequence and applies an FFT across those samples so beat-frequency or delay structure becomes a set of range bins. The contract should say whether bins are in raw order, shifted order, or truncated to a selected region, and how zero or DC bins are interpreted relative to physical range.

## Clocking, Reset, and Timing Assumptions

The incoming samples must match the documented chirp or pulse frame exactly and preserve coherence across the full fast-time window. Reset should clear any partial block assembly so the next chirp or pulse begins from a known range-transform state.

## Latency, Throughput, and Resource Considerations

Range FFT cost is moderate and is often repeated for every chirp and every receive channel, so throughput and memory organization matter. Resource use depends on FFT size, precision, and whether several channels are processed in parallel.

## Verification Strategy

- Compare emitted bins against a trusted FFT reference using synthetic delayed targets and multi-target scenes.
- Check bin ordering, scaling, windowing, and profile switching.
- Verify reset and incomplete block handling at chirp or pulse boundaries.

## Integration Notes and Dependencies

This block usually follows dechirp or matched filtering and feeds Doppler processing or range map builders, so bin ordering and scaling should be documented with those neighboring stages. Integrators should also state whether downstream logic expects complex bins or already reduced magnitudes.

## Edge Cases, Failure Modes, and Design Risks

- A DC-bin or zero-range convention mismatch can shift physical interpretation without changing apparent spectral structure.
- Fast-time boundary errors smear energy across bins and may resemble front-end noise or leakage.
- Undocumented scaling choices can make CFAR thresholds and map displays nonportable across builds.

## Related Modules In This Domain

- dechirp_mixer
- range_doppler_builder
- doppler_fft

## Documentation Status

This MODULE.md is the current deep, domain-specific reference for the Range FFT module in the library taxonomy. When RTL is added or refined, the implementation should either match this contract or the document should be updated to reflect the implemented behavior exactly.
